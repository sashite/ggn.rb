# frozen_string_literal: true

require "sashite-lcn"
require "sashite-qpi"

module Sashite
  module Ggn
    class Ruleset
      class Source
        class Destination
          # Movement possibility evaluator
          #
          # Evaluates whether movements are possible based on environmental
          # pre-conditions as defined in the GGN specification v1.0.0.
          #
          # The Engine acts as the final stage in the GGN navigation chain,
          # determining which movement possibilities from the GGN data structure
          # are valid given the current board state.
          #
          # @see https://sashite.dev/specs/ggn/1.0.0/
          class Engine
            # Create a new Engine with movement possibilities
            #
            # @note This constructor is typically called internally through the
            #   navigation chain: ruleset.select(piece).from(source).to(destination)
            #
            # @param possibilities [Array<Hash>] Array of movement possibility
            #   objects from the GGN data structure. Each possibility must contain
            #   "must" and "deny" fields with LCN-formatted conditions.
            #
            # @example Structure of a possibility
            #   {
            #     "must" => { "e3" => "empty", "e4" => "empty" },
            #     "deny" => { "f3" => "enemy" }
            #   }
            def initialize(*possibilities)
              @possibilities = validate_and_freeze(possibilities)

              freeze
            end

            # Evaluate which movement possibilities match the current position
            #
            # Returns the subset of movement possibilities whose pre-conditions
            # are satisfied by the current board state. This is the core evaluation
            # method that determines if a movement is pseudo-legal.
            #
            # Each possibility is evaluated independently with the following logic:
            # - All "must" conditions must be satisfied (AND logic)
            # - No "deny" conditions can be satisfied (NOR logic)
            #
            # The "enemy" keyword in conditions is evaluated from the active
            # player's perspective, following the LCN specification's standard
            # interpretation.
            #
            # @param active_side [Symbol] Active player side (:first or :second).
            #   This determines which pieces are considered "enemy" when evaluating
            #   the "enemy" keyword in conditions.
            # @param squares [Hash{String => String, nil}] Current board state mapping
            #   CELL coordinates to QPI piece identifiers. Use nil for empty squares.
            #   Only squares referenced in conditions need to be included.
            #
            # @return [Array<Hash>] Subset of movement possibilities that satisfy their
            #   pre-conditions. Each returned Hash is the original possibility from the
            #   GGN data, containing at minimum "must" and "deny" fields.
            #   Returns an empty array if no possibilities match.
            #
            # @raise [ArgumentError] if active_side is not :first or :second
            #
            # @example Chess pawn two-square advance
            #   active_side = :first
            #   squares = {
            #     "e2" => "C:P",  # White pawn on starting square
            #     "e3" => nil,    # Path must be clear
            #     "e4" => nil     # Destination must be empty
            #   }
            #   possibilities = engine.where(active_side, squares)
            #   # => [{"must" => {"e3" => "empty", "e4" => "empty"}, "deny" => {}}]
            #
            # @example Capture evaluation with enemy keyword
            #   active_side = :first
            #   squares = {
            #     "e4" => "C:P",  # White pawn
            #     "d5" => "c:p"   # Black pawn (enemy from white's perspective)
            #   }
            #   possibilities = engine.where(active_side, squares)
            #   # => [{"must" => {"d5" => "enemy"}, "deny" => {}}]
            #
            # @example No matching possibilities (blocked path)
            #   squares = { "e2" => "C:P", "e3" => "c:p", "e4" => nil }
            #   possibilities = engine.where(active_side, squares)
            #   # => []
            def where(active_side, squares)
              validate_active_side!(active_side)
              validate_squares!(squares)

              @possibilities.select do |possibility|
                satisfies_conditions?(possibility, active_side, squares)
              end
            end

            private

            # Validate and freeze the possibilities array
            #
            # @param possibilities [Array<Hash>] Possibilities to validate
            # @return [Array<Hash>] Frozen array of validated possibilities
            # @raise [ArgumentError] if possibilities structure is invalid
            def validate_and_freeze(possibilities)
              raise ::ArgumentError, "Possibilities must be an Array" unless possibilities.is_a?(::Array)

              possibilities.each do |possibility|
                raise ::ArgumentError, "Each possibility must be a Hash" unless possibility.is_a?(::Hash)

                unless possibility.key?("must") && possibility.key?("deny")
                  raise ::ArgumentError, "Possibility must have 'must' and 'deny' fields"
                end
              end

              possibilities.freeze
            end

            # Validate the active_side parameter
            #
            # @param active_side [Symbol] Side to validate
            # @raise [ArgumentError] if side is invalid
            def validate_active_side!(active_side)
              return if %i[first second].include?(active_side)

              raise ::ArgumentError, "active_side must be :first or :second, got: #{active_side.inspect}"
            end

            # Validate the squares parameter
            #
            # @param squares [Hash] Squares to validate
            # @raise [ArgumentError] if squares is not a Hash
            def validate_squares!(squares)
              return if squares.is_a?(Hash)

              raise ::ArgumentError, "squares must be a Hash, got: #{squares.class}"
            end

            # Check if a possibility's conditions are satisfied
            #
            # @param possibility [Hash] Movement possibility with "must" and "deny"
            # @param active_side [Symbol] Active player side
            # @param squares [Hash] Board state
            # @return [Boolean] true if all conditions are satisfied
            def satisfies_conditions?(possibility, active_side, squares)
              must_conditions = possibility.fetch("must", {})
              deny_conditions = possibility.fetch("deny", {})

              satisfies_must?(must_conditions, active_side, squares) &&
                satisfies_deny?(deny_conditions, active_side, squares)
            end

            # Check if all 'must' conditions are satisfied
            #
            # @param conditions [Hash] LCN conditions that must be true
            # @param active_side [Symbol] Active player side
            # @param squares [Hash] Board state
            # @return [Boolean] true if all conditions are met
            def satisfies_must?(conditions, active_side, squares)
              return true if conditions.nil? || conditions.empty?

              evaluate_lcn_conditions(conditions, active_side, squares, :all?)
            end

            # Check if no 'deny' conditions are satisfied
            #
            # @param conditions [Hash] LCN conditions that must be false
            # @param active_side [Symbol] Active player side
            # @param squares [Hash] Board state
            # @return [Boolean] true if none of the conditions are met
            def satisfies_deny?(conditions, active_side, squares)
              return true if conditions.nil? || conditions.empty?

              evaluate_lcn_conditions(conditions, active_side, squares, :none?)
            end

            # Evaluate LCN conditions using specified logic
            #
            # @param conditions [Hash] LCN conditions to evaluate
            # @param active_side [Symbol] Active player side
            # @param squares [Hash] Board state
            # @param logic_method [Symbol] :all? or :none? for AND/NOR logic
            # @return [Boolean] Result of condition evaluation
            def evaluate_lcn_conditions(conditions, active_side, squares, logic_method)
              # Parse conditions through LCN for validation
              lcn = ::Sashite::Lcn.parse(conditions)

              # Evaluate each location condition using the specified logic
              lcn.locations.public_send(logic_method) do |location|
                expected_state = lcn[location]
                location_matches?(location.to_s, expected_state, active_side, squares)
              end
            end

            # Check if a specific location matches expected state
            #
            # Evaluates a single location condition against the board state.
            # Handles the three types of LCN state values:
            # - "empty": location must be unoccupied
            # - "enemy": location must contain an opponent's piece
            # - QPI identifier: location must contain exactly this piece
            #
            # @param location [String] CELL coordinate to check
            # @param expected_state [String] Expected state value from LCN
            # @param active_side [Symbol] Active player side for enemy evaluation
            # @param squares [Hash] Board state
            # @return [Boolean] true if location matches expected state
            def location_matches?(location, expected_state, active_side, squares)
              actual_value = squares[location]

              case expected_state
              when "empty"
                # Location must be unoccupied
                actual_value.nil?
              when "enemy"
                # Location must contain opponent's piece
                # nil check prevents false positives on empty squares
                !actual_value.nil? && enemy_piece?(actual_value, active_side)
              else
                # Direct QPI comparison for specific piece requirement
                actual_value == expected_state
              end
            end

            # Determine if a piece belongs to the opponent
            #
            # Uses QPI parsing to extract the piece's side and compares it
            # with the active player's side. A piece is considered enemy if
            # its side differs from the active player's side.
            #
            # @param qpi_identifier [String] QPI piece identifier (e.g., "C:K", "c:p")
            # @param active_side [Symbol] Active player side (:first or :second)
            # @return [Boolean] true if piece belongs to opponent
            def enemy_piece?(qpi_identifier, active_side)
              piece = ::Sashite::Qpi.parse(qpi_identifier)
              piece.side != active_side
            end
          end
        end
      end
    end
  end
end
