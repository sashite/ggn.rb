# frozen_string_literal: true

require_relative File.join("..", "..", "..", "move_validator")
require_relative File.join("engine", "transition")

module Sashite
  module Ggn
    class Ruleset
      class Source
        class Destination
          # Evaluates pseudo-legal move conditions for a specific source-destination pair.
          #
          # The Engine is the core logic component that determines whether a move
          # is valid under the basic movement constraints defined in GGN. It evaluates
          # require/prevent conditions and returns the resulting board transformation.
          #
          # Since GGN focuses exclusively on board-to-board transformations, the Engine
          # only handles pieces moving, capturing, or transforming on the game board.
          #
          # The class uses a functional approach with filter_map for optimal performance
          # and clean, readable code that avoids mutation of external variables.
          #
          # @example Evaluating a simple move
          #   engine = destinations.to('e4')
          #   transitions = engine.where(board_state, 'CHESS')
          #   puts "Move valid!" if transitions.any?
          #
          # @example Handling promotion choices
          #   engine = destinations.to('e8')  # pawn promotion
          #   transitions = engine.where(board_state, 'CHESS')
          #   transitions.each_with_index do |t, i|
          #     puts "Choice #{i + 1}: promotes to #{t.diff['e8']}"
          #   end
          class Engine
            include MoveValidator

            # Creates a new Engine with conditional transition rules.
            #
            # @param transitions [Array] Transition rules as individual arguments,
            #   each containing require/prevent conditions and perform actions.
            # @param actor [String] GAN identifier of the piece being moved
            # @param origin [String] Source square
            # @param target [String] Destination square
            #
            # @raise [ArgumentError] If parameters are invalid
            #
            # @example Creating an engine for a pawn move
            #   transition_rules = [
            #     {
            #       "require" => { "e4" => "empty", "e3" => "empty" },
            #       "perform" => { "e2" => nil, "e4" => "CHESS:P" }
            #     }
            #   ]
            #   engine = Engine.new(*transition_rules, actor: "CHESS:P", origin: "e2", target: "e4")
            def initialize(*transitions, actor:, origin:, target:)
              raise ::ArgumentError, "actor must be a String" unless actor.is_a?(::String)
              raise ::ArgumentError, "origin must be a String" unless origin.is_a?(::String)
              raise ::ArgumentError, "target must be a String" unless target.is_a?(::String)

              @transitions = transitions
              @actor = actor
              @origin = origin
              @target = target

              freeze
            end

            # Evaluates move validity and returns all resulting transitions.
            #
            # Uses a functional approach with filter_map to process transitions efficiently.
            # This method checks each conditional transition and returns all that match the
            # current board state, supporting multiple promotion choices and optional
            # transformations as defined in the GGN specification.
            #
            # @param board_state [Hash] Current board state mapping square labels
            #   to piece identifiers (nil for empty squares)
            # @param active_game [String] Current player's game identifier (e.g., 'CHESS', 'shogi').
            #   This corresponds to the first element of the GAMES-TURN field in FEEN notation.
            #
            # @return [Array<Transition>] Array of Transition objects for all valid variants,
            #   empty array if no valid transitions exist
            #
            # @raise [ArgumentError] If any parameter is invalid or malformed
            #
            # @example Single valid move
            #   board_state = { 'e2' => 'CHESS:P', 'e3' => nil, 'e4' => nil }
            #   transitions = engine.where(board_state, 'CHESS')
            #   transitions.size  # => 1
            #   transitions.first.diff  # => { 'e2' => nil, 'e4' => 'CHESS:P' }
            #
            # @example Multiple promotion choices
            #   board_state = { 'e7' => 'CHESS:P', 'e8' => nil }
            #   transitions = engine.where(board_state, 'CHESS')
            #   transitions.size  # => 4 (Queen, Rook, Bishop, Knight)
            #   transitions.map { |t| t.diff['e8'] }  # => ['CHESS:Q', 'CHESS:R', 'CHESS:B', 'CHESS:N']
            #
            # @example Invalid move (wrong piece)
            #   board_state = { 'e2' => 'CHESS:Q', 'e3' => nil, 'e4' => nil }
            #   transitions = engine.where(board_state, 'CHESS')  # => []
            #
            # @example Invalid move (blocked path)
            #   board_state = { 'e2' => 'CHESS:P', 'e3' => 'CHESS:N', 'e4' => nil }
            #   transitions = engine.where(board_state, 'CHESS')  # => []
            def where(board_state, active_game)
              # Validate all input parameters before processing
              validate_parameters!(board_state, active_game)

              # Early return if basic move context is invalid (wrong piece, wrong player, etc.)
              return [] unless valid_move_context?(board_state, active_game)

              # Use filter_map for functional approach: filter valid transitions and map to Transition objects
              # This avoids mutation and is more performant than select + map for large datasets
              @transitions.filter_map do |transition|
                # Only create Transition objects for transitions that match current board state
                create_transition(transition) if transition_matches?(transition, board_state, active_game)
              end
            end

            private

            # Validates the move context before checking pseudo-legality.
            # Uses the shared MoveValidator module for consistency across the codebase.
            #
            # This method performs essential pre-checks:
            # - Ensures the piece is at the expected origin square
            # - Ensures the piece belongs to the current player
            #
            # @param board_state [Hash] Current board state
            # @param active_game [String] Current player identifier
            #
            # @return [Boolean] true if the move context is valid
            def valid_move_context?(board_state, active_game)
              # For all moves, piece must be on the board at origin square
              return false unless piece_on_board_at_origin?(@actor, @origin, board_state)

              # Verify piece ownership - only current player can move their pieces
              piece_belongs_to_current_player?(@actor, active_game)
            end

            # Creates a new Transition object from a transition rule.
            # Extracted to improve readability and maintainability of the main logic.
            #
            # Note: GGN no longer supports gain/drop fields, so Transition creation
            # is simplified to only handle board transformations.
            #
            # @param transition [Hash] The transition rule containing perform data
            #
            # @return [Transition] A new immutable Transition object
            def create_transition(transition)
              Transition.new(**transition["perform"])
            end

            # Validates all parameters in one consolidated method.
            # Provides comprehensive validation with clear error messages for debugging.
            #
            # @param board_state [Object] Should be a Hash
            # @param active_game [Object] Should be a String
            #
            # @raise [ArgumentError] If any parameter is invalid
            def validate_parameters!(board_state, active_game)
              # Type validation with clear error messages
              unless board_state.is_a?(::Hash)
                raise ::ArgumentError, "board_state must be a Hash, got #{board_state.class}"
              end

              unless active_game.is_a?(::String)
                raise ::ArgumentError, "active_game must be a String, got #{active_game.class}"
              end

              # Content validation - ensures data integrity
              validate_board_state!(board_state)
              validate_active_game!(active_game)
            end

            # Validates board_state structure and content.
            # Ensures all square labels and piece identifiers are properly formatted.
            #
            # @param board_state [Hash] Board state to validate
            #
            # @raise [ArgumentError] If board_state contains invalid data
            def validate_board_state!(board_state)
              board_state.each do |square, piece|
                validate_square_label!(square)
                validate_board_piece!(piece, square)
              end
            end

            # Validates a square label according to GGN requirements.
            # Square labels must be non-empty strings.
            #
            # @param square [Object] Square label to validate
            #
            # @raise [ArgumentError] If square label is invalid
            def validate_square_label!(square)
              unless square.is_a?(::String) && !square.empty?
                raise ::ArgumentError, "Invalid square label: #{square.inspect}. Must be a non-empty String."
              end
            end

            # Validates a piece on the board.
            # Pieces can be nil (empty square) or valid GAN identifiers.
            #
            # @param piece [Object] Piece to validate
            # @param square [String] Square where piece is located (for error context)
            #
            # @raise [ArgumentError] If piece is invalid
            def validate_board_piece!(piece, square)
              return if piece.nil? # Empty squares are valid

              unless piece.is_a?(::String)
                raise ::ArgumentError, "Invalid piece at square #{square}: #{piece.inspect}. Must be a String or nil."
              end

              unless valid_gan_identifier?(piece)
                raise ::ArgumentError, "Invalid GAN identifier at square #{square}: #{piece.inspect}. Must follow GAN format (e.g., 'CHESS:P', 'shogi:+k')."
              end
            end

            # Validates active_game format according to GAN specification.
            # Active game must be a non-empty alphabetic game identifier.
            #
            # @param active_game [String] Active game identifier to validate
            #
            # @raise [ArgumentError] If active game format is invalid
            def validate_active_game!(active_game)
              if active_game.empty?
                raise ::ArgumentError, "active_game cannot be empty"
              end

              unless valid_game_identifier?(active_game)
                raise ::ArgumentError, "Invalid active_game format: #{active_game.inspect}. Must be a valid game identifier (alphabetic characters only, e.g., 'CHESS', 'shogi')."
              end
            end

            # Validates if a string is a valid GAN identifier with casing consistency.
            # Ensures game part and piece part have consistent casing (both upper or both lower).
            #
            # @param identifier [String] GAN identifier to validate
            #
            # @return [Boolean] true if valid GAN format
            def valid_gan_identifier?(identifier)
              return false unless identifier.include?(':')

              game_part, piece_part = identifier.split(':', 2)

              return false unless valid_game_identifier?(game_part)
              return false if piece_part.empty?
              return false unless /\A[-+]?[A-Za-z]'?\z/.match?(piece_part)

              # Extract base letter and check casing consistency
              base_letter = piece_part.gsub(/\A[-+]?([A-Za-z])'?\z/, '\1')

              # Ensure consistent casing between game and piece parts
              if game_part == game_part.upcase
                base_letter == base_letter.upcase
              else
                base_letter == base_letter.downcase
              end
            end

            # Checks if a transition matches the current board state.
            # Evaluates both require conditions (must be true) and prevent conditions (must be false).
            #
            # @param transition [Hash] The transition rule to evaluate
            # @param board_state [Hash] Current board state
            # @param active_game [String] Current player identifier
            #
            # @return [Boolean] true if the transition is valid for current state
            def transition_matches?(transition, board_state, active_game)
              # Ensure transition is properly formatted
              return false unless transition.is_a?(::Hash) && transition.key?("perform")

              # Check require conditions (all must be satisfied - logical AND)
              return false if has_require_conditions?(transition) && !check_require_conditions(transition["require"], board_state, active_game)

              # Check prevent conditions (none must be satisfied - logical NOR)
              return false if has_prevent_conditions?(transition) && !check_prevent_conditions(transition["prevent"], board_state, active_game)

              true
            end

            # Checks if transition has require conditions that need validation.
            #
            # @param transition [Hash] The transition rule
            #
            # @return [Boolean] true if require conditions exist
            def has_require_conditions?(transition)
              transition["require"]&.is_a?(::Hash) && !transition["require"].empty?
            end

            # Checks if transition has prevent conditions that need validation.
            #
            # @param transition [Hash] The transition rule
            #
            # @return [Boolean] true if prevent conditions exist
            def has_prevent_conditions?(transition)
              transition["prevent"]&.is_a?(::Hash) && !transition["prevent"].empty?
            end

            # Verifies all require conditions are satisfied (logical AND).
            # All specified conditions must be true for the move to be valid.
            #
            # @param require_conditions [Hash] Square -> required state mappings
            # @param board_state [Hash] Current board state
            # @param active_game [String] Current player identifier
            #
            # @return [Boolean] true if all conditions are satisfied
            def check_require_conditions(require_conditions, board_state, active_game)
              require_conditions.all? do |square, required_state|
                actual_piece = board_state[square]
                matches_state?(actual_piece, required_state, active_game)
              end
            end

            # Verifies none of the prevent conditions are satisfied (logical NOR).
            # If any prevent condition is true, the move is invalid.
            #
            # @param prevent_conditions [Hash] Square -> forbidden state mappings
            # @param board_state [Hash] Current board state
            # @param active_game [String] Current player identifier
            #
            # @return [Boolean] true if no forbidden conditions are satisfied
            def check_prevent_conditions(prevent_conditions, board_state, active_game)
              prevent_conditions.none? do |square, forbidden_state|
                actual_piece = board_state[square]
                matches_state?(actual_piece, forbidden_state, active_game)
              end
            end

            # Determines if a piece matches a required/forbidden state.
            # Handles special states ("empty", "enemy") and exact piece matching.
            #
            # @param actual_piece [String, nil] The piece currently on the square
            # @param expected_state [String] The expected/forbidden state
            # @param active_game [String] Current player identifier
            #
            # @return [Boolean] true if the piece matches the expected state
            def matches_state?(actual_piece, expected_state, active_game)
              case expected_state
              when "empty"
                actual_piece.nil?
              when "enemy"
                actual_piece && enemy_piece?(actual_piece, active_game)
              else
                # Exact piece match
                actual_piece == expected_state
              end
            end

            # Determines if a piece belongs to the opposing player.
            # Uses GAN casing conventions to determine ownership based on case correspondence.
            #
            # @param piece [String] The piece identifier to check (must be GAN format)
            # @param active_game [String] Current player identifier
            #
            # @return [Boolean] true if piece belongs to opponent
            def enemy_piece?(piece, active_game)
              return false if piece.nil? || piece.empty?
              return false unless piece.include?(':')

              # Use GAN format for ownership determination
              game_part = piece.split(':', 2).fetch(0)
              piece_is_uppercase_player = game_part == game_part.upcase
              current_is_uppercase_player = active_game == active_game.upcase

              # Enemy if players have different casing
              piece_is_uppercase_player != current_is_uppercase_player
            end
          end
        end
      end
    end
  end
end
