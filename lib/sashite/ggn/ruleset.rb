# frozen_string_literal: true

require_relative "move_validator"
require_relative File.join("ruleset", "source")

module Sashite
  module Ggn
    # Represents a collection of piece definitions from a GGN document.
    #
    # A Ruleset instance contains all the pseudo-legal move definitions for
    # various game pieces, organized by their GAN (General Actor Notation)
    # identifiers. This class provides the entry point for querying specific
    # piece movement rules and generating all possible transitions for a given
    # game state.
    #
    # The class uses functional programming principles throughout, leveraging
    # Ruby's Enumerable methods (flat_map, filter_map, select) to create
    # efficient, readable, and maintainable code that avoids mutation and
    # side effects.
    #
    # GGN focuses exclusively on board-to-board transformations. All moves
    # represent pieces moving, capturing, or transforming on the game board.
    #
    # = Validation Behavior
    #
    # When `validate: true` (default), performs:
    # - Logical contradiction detection in require/prevent conditions
    # - Implicit requirement duplication detection
    #
    # When `validate: false`, skips all internal validations for maximum performance.
    #
    # @example Basic usage
    #   piece_data = Sashite::Ggn.load_file('chess.json')
    #   chess_king = piece_data.select('CHESS:K')
    #   shogi_pawn = piece_data.select('SHOGI:P')
    #
    # @example Complete workflow
    #   piece_data = Sashite::Ggn.load_file('game_moves.json')
    #
    #   # Query specific piece moves
    #   begin
    #     king_source = piece_data.select('CHESS:K')
    #     puts "Found chess king movement rules"
    #   rescue KeyError
    #     puts "Chess king not found in this dataset"
    #   end
    #
    # @example Finding all possible moves in a position
    #   board_state = { 'e1' => 'CHESS:K', 'e2' => 'CHESS:P', 'd1' => 'CHESS:Q' }
    #   all_moves = piece_data.pseudo_legal_transitions(board_state, 'CHESS')
    #   puts "Found #{all_moves.size} possible moves"
    #
    # @see https://sashite.dev/documents/gan/ GAN Specification
    # @see https://sashite.dev/documents/ggn/ GGN Specification
    class Ruleset
      include MoveValidator

      # Creates a new Ruleset instance from GGN data.
      #
      # @param data [Hash] The parsed GGN JSON data structure, where keys are
      #   GAN identifiers and values contain the movement definitions.
      # @param validate [Boolean] Whether to perform internal validations (default: true).
      #   When false, skips logical contradiction and implicit requirement checks
      #   for maximum performance.
      #
      # @raise [ArgumentError] If data is not a Hash
      # @raise [ValidationError] If validation is enabled and logical issues are found
      #
      # @example Creating from parsed JSON data with full validation
      #   ggn_data = JSON.parse(File.read('chess.json'))
      #   ruleset = Ruleset.new(ggn_data)  # validate: true by default
      #
      # @example Creating without validation for performance
      #   ggn_data = JSON.parse(File.read('large_dataset.json'))
      #   ruleset = Ruleset.new(ggn_data, validate: false)
      def initialize(data, validate: true)
        raise ::ArgumentError, "Expected Hash, got #{data.class}" unless data.is_a?(::Hash)

        @data = data

        if validate
          # Perform enhanced validations for logical consistency
          validate_no_implicit_requirement_duplications!
          validate_no_logical_contradictions!
        end

        freeze
      end

      # Retrieves movement rules for a specific piece type.
      #
      # @param actor [String] The GAN identifier for the piece type
      #   (e.g., 'CHESS:K', 'SHOGI:P', 'chess:q'). Must match exactly
      #   including case sensitivity.
      #
      # @return [Source] A Source instance containing all movement rules
      #   for this piece type from different board positions.
      #
      # @raise [KeyError] If the actor is not found in the GGN data
      #
      # @example Fetching chess king moves
      #   source = piece_data.select('CHESS:K')
      #   destinations = source.from('e1')
      #   engine = destinations.to('e2')
      #
      # @example Handling missing pieces
      #   begin
      #     moves = piece_data.select('NONEXISTENT:X')
      #   rescue KeyError => e
      #     puts "Piece not found: #{e.message}"
      #   end
      #
      # @note The actor format must follow GAN specification:
      #   GAME:piece (e.g., CHESS:K, shogi:p, XIANGQI:E)
      def select(actor)
        data = @data.fetch(actor)
        Source.new(data, actor: actor)
      end

      # Returns all pseudo-legal move transitions for the given position.
      #
      # This method traverses all actors defined in the GGN data using a functional
      # approach with flat_map and filter_map to efficiently process and filter
      # valid moves. Each result contains the complete transition information
      # including all variants for moves with multiple outcomes (e.g., promotion choices).
      #
      # The implementation uses a three-level functional decomposition:
      # 1. Process each actor (piece type) that belongs to current player
      # 2. Process each valid origin position for that actor
      # 3. Process each destination and evaluate transition rules
      #
      # @param board_state [Hash] Current board state mapping square labels
      #   to piece identifiers (nil for empty squares)
      # @param active_game [String] Current player's game identifier (e.g., 'CHESS', 'shogi').
      #   This corresponds to the first element of the GAMES-TURN field in FEEN notation.
      #
      # @return [Array<Array>] List of move transitions, where each element is:
      #   [actor, origin, target, transitions]
      #   - actor [String]: GAN identifier of the moving piece
      #   - origin [String]: Source square
      #   - target [String]: Destination square
      #   - transitions [Array<Transition>]: All valid transition variants
      #
      # @raise [ArgumentError] If any parameter is invalid or malformed
      #
      # @example Getting all possible transitions including promotion variants
      #   board_state = { 'e7' => 'CHESS:P', 'e8' => nil }
      #   transitions = piece_data.pseudo_legal_transitions(board_state, 'CHESS')
      #   # => [
      #   #   ["CHESS:P", "e7", "e8", [
      #   #     #<Transition diff={"e7"=>nil, "e8"=>"CHESS:Q"}>,
      #   #     #<Transition diff={"e7"=>nil, "e8"=>"CHESS:R"}>,
      #   #     #<Transition diff={"e7"=>nil, "e8"=>"CHESS:B"}>,
      #   #     #<Transition diff={"e7"=>nil, "e8"=>"CHESS:N"}>
      #   #   ]]
      #   # ]
      #
      # @example Processing grouped transitions
      #   transitions = piece_data.pseudo_legal_transitions(board_state, 'CHESS')
      #   transitions.each do |actor, origin, target, variants|
      #     puts "#{actor} from #{origin} to #{target}:"
      #     variants.each_with_index do |transition, i|
      #       puts "  Variant #{i + 1}: #{transition.diff}"
      #     end
      #   end
      #
      # @example Filtering for specific move types
      #   # Find all promotion moves
      #   promotions = piece_data.pseudo_legal_transitions(board_state, 'CHESS')
      #     .select { |actor, origin, target, variants| variants.size > 1 }
      #
      #   # Find all multi-square moves (like castling)
      #   complex_moves = piece_data.pseudo_legal_transitions(board_state, 'CHESS')
      #     .select { |actor, origin, target, variants|
      #       variants.any? { |t| t.diff.keys.size > 2 }
      #     }
      #
      # @example Performance considerations
      #   # For large datasets, consider filtering by piece type first
      #   specific_piece_moves = piece_data.select('CHESS:Q')
      #     .from('d1').to('d8').where(board_state, 'CHESS')
      def pseudo_legal_transitions(board_state, active_game)
        validate_pseudo_legal_parameters!(board_state, active_game)

        # Use flat_map to process all actors and flatten the results in one pass
        # This functional approach avoids mutation and intermediate arrays
        @data.flat_map do |actor, source_data|
          # Early filter: only process pieces belonging to current player
          # This optimization significantly reduces processing time
          next [] unless piece_belongs_to_current_player?(actor, active_game)

          # Process all source positions for this actor using functional decomposition
          process_actor_transitions(actor, source_data, board_state, active_game)
        end
      end

      private

      # Processes all possible transitions for a single actor (piece type).
      #
      # This method represents the second level of functional decomposition,
      # handling all source positions (origins) for a given piece type.
      # It uses flat_map to efficiently process each origin and flatten the results.
      #
      # @param actor [String] GAN identifier of the piece type
      # @param source_data [Hash] Movement data for this piece type, mapping
      #   origin squares to destination data
      # @param board_state [Hash] Current board state
      # @param active_game [String] Current player identifier
      #
      # @return [Array] Array of valid transition tuples for this actor
      #
      # @example Source data structure
      #   {
      #     "e1" => { "e2" => [...], "f1" => [...] }  # Regular moves
      #   }
      def process_actor_transitions(actor, source_data, board_state, active_game)
        source_data.flat_map do |origin, destination_data|
          # Early filter: check piece presence at origin square
          # Piece must be present at origin square for the move to be valid
          next [] unless piece_on_board_at_origin?(actor, origin, board_state)

          # Process all destination squares for this origin
          process_origin_transitions(actor, origin, destination_data, board_state, active_game)
        end
      end

      # Processes all possible transitions from a single origin square.
      #
      # This method represents the third level of functional decomposition,
      # handling all destination squares from a given origin. It creates
      # engines to evaluate each move and uses filter_map to efficiently
      # combine filtering and transformation operations.
      #
      # @param actor [String] GAN identifier of the piece
      # @param origin [String] Source square
      # @param destination_data [Hash] Available destinations and their transition rules
      # @param board_state [Hash] Current board state
      # @param active_game [String] Current player identifier
      #
      # @return [Array] Array of valid transition tuples for this origin
      #
      # @example Destination data structure
      #   {
      #     "e4" => [
      #       { "require" => { "e4" => "empty" }, "perform" => { "e2" => nil, "e4" => "CHESS:P" } }
      #     ],
      #     "f3" => [
      #       { "require" => { "f3" => "enemy" }, "perform" => { "e2" => nil, "f3" => "CHESS:P" } }
      #     ]
      #   }
      def process_origin_transitions(actor, origin, destination_data, board_state, active_game)
        destination_data.filter_map do |target, transition_rules|
          # Create engine to evaluate this specific source-destination pair
          # Each engine encapsulates the conditional logic for one move
          engine = Source::Destination::Engine.new(*transition_rules, actor: actor, origin: origin, target: target)

          # Get all valid transitions for this move (supports multiple variants)
          # The engine handles require/prevent conditions and returns Transition objects
          transitions = engine.where(board_state, active_game)

          # Only return successful moves (with at least one valid transition)
          # filter_map automatically filters out nil values
          [actor, origin, target, transitions] unless transitions.empty?
        end
      end

      # Validates parameters for pseudo_legal_transitions method.
      #
      # Provides comprehensive validation with clear error messages for debugging.
      # This method ensures data integrity and helps catch common usage errors
      # early in the processing pipeline.
      #
      # @param board_state [Object] Should be a Hash mapping squares to pieces
      # @param active_game [Object] Should be a String representing current player's game
      #
      # @raise [ArgumentError] If any parameter is invalid
      #
      # @example Valid parameters
      #   validate_pseudo_legal_parameters!(
      #     { "e1" => "CHESS:K", "e2" => nil },
      #     "CHESS"
      #   )
      #
      # @example Invalid parameters (raises ArgumentError)
      #   validate_pseudo_legal_parameters!("invalid", "CHESS")
      #   validate_pseudo_legal_parameters!({}, 123)
      #   validate_pseudo_legal_parameters!({}, "")
      def validate_pseudo_legal_parameters!(board_state, active_game)
        # Type validation with clear, specific error messages
        unless board_state.is_a?(::Hash)
          raise ::ArgumentError, "board_state must be a Hash, got #{board_state.class}"
        end

        unless active_game.is_a?(::String)
          raise ::ArgumentError, "active_game must be a String, got #{active_game.class}"
        end

        # Content validation - ensures meaningful data
        if active_game.empty?
          raise ::ArgumentError, "active_game cannot be empty"
        end

        unless valid_game_identifier?(active_game)
          raise ::ArgumentError, "Invalid active_game format: #{active_game.inspect}. Must be a valid game identifier (alphabetic characters only, e.g., 'CHESS', 'shogi')."
        end

        # Validate board_state structure
        validate_board_state_structure!(board_state)
      end

      # Validates board_state structure.
      #
      # Ensures all square labels are valid strings and all pieces are either nil
      # or valid strings. This validation helps catch common integration errors
      # where malformed board states are passed to the GGN engine.
      #
      # @param board_state [Hash] Board state to validate
      #
      # @raise [ArgumentError] If board_state contains invalid data
      #
      # @example Valid board state
      #   { "e1" => "CHESS:K", "e2" => nil, "d1" => "CHESS:Q" }
      #
      # @example Invalid board states (would raise ArgumentError)
      #   { 123 => "CHESS:K" }           # Invalid square label
      #   { "e1" => "" }                 # Empty piece string
      #   { "e1" => 456 }                # Non-string piece
      def validate_board_state_structure!(board_state)
        board_state.each do |square, piece|
          unless square.is_a?(::String) && !square.empty?
            raise ::ArgumentError, "Invalid square label: #{square.inspect}. Must be a non-empty String."
          end

          if piece && (!piece.is_a?(::String) || piece.empty?)
            raise ::ArgumentError, "Invalid piece at #{square}: #{piece.inspect}. Must be a String or nil."
          end
        end
      end

      # Validates that transitions don't duplicate implicit requirements in the require field.
      #
      # According to GGN specification, implicit requirements (like the source piece
      # being present at the source square) should NOT be explicitly specified in
      # the require field, as this creates redundancy and potential inconsistency.
      #
      # @raise [ValidationError] If any transition duplicates implicit requirements
      #
      # @example Invalid GGN that would be rejected
      #   {
      #     "CHESS:K": {
      #       "e1": {
      #         "e2": [{
      #           "require": { "e1": "CHESS:K" },  # ❌ Redundant implicit requirement
      #           "perform": { "e1": null, "e2": "CHESS:K" }
      #         }]
      #       }
      #     }
      #   }
      def validate_no_implicit_requirement_duplications!
        @data.each do |actor, source_data|
          source_data.each do |origin, destination_data|
            destination_data.each do |target, transition_list|
              transition_list.each_with_index do |transition, index|
                validate_single_transition_implicit_requirements!(
                  transition, actor, origin, target, index
                )
              end
            end
          end
        end
      end

      # Validates a single transition for implicit requirement duplication.
      #
      # @param transition [Hash] The transition rule to validate
      # @param actor [String] GAN identifier of the piece
      # @param origin [String] Source square
      # @param target [String] Destination square
      # @param index [Integer] Index of transition for error reporting
      #
      # @raise [ValidationError] If implicit requirements are duplicated
      def validate_single_transition_implicit_requirements!(transition, actor, origin, target, index)
        return unless transition.is_a?(::Hash) && transition["require"].is_a?(::Hash)

        require_conditions = transition["require"]

        # Check if the source square requirement is explicitly specified
        if require_conditions.key?(origin) && require_conditions[origin] == actor
          raise ValidationError,
            "Implicit requirement duplication detected in #{actor} from #{origin} to #{target} " \
            "(transition #{index}): 'require' field explicitly specifies that #{origin} contains #{actor}, " \
            "but this is already implicit from the move structure. Remove this redundant requirement."
        end
      end

      # Validates that transitions don't contain logical contradictions between require and prevent.
      #
      # A logical contradiction occurs when the same square is required to be in
      # the same state in both require and prevent fields. This creates an impossible
      # condition that can never be satisfied.
      #
      # @raise [ValidationError] If any transition contains logical contradictions
      #
      # @example Invalid GGN that would be rejected
      #   {
      #     "CHESS:B": {
      #       "c1": {
      #         "f4": [{
      #           "require": { "d2": "empty" },
      #           "prevent": { "d2": "empty" },  # ❌ Logical contradiction
      #           "perform": { "c1": null, "f4": "CHESS:B" }
      #         }]
      #       }
      #     }
      #   }
      def validate_no_logical_contradictions!
        @data.each do |actor, source_data|
          source_data.each do |origin, destination_data|
            destination_data.each do |target, transition_list|
              transition_list.each_with_index do |transition, index|
                validate_single_transition_logical_consistency!(
                  transition, actor, origin, target, index
                )
              end
            end
          end
        end
      end

      # Validates a single transition for logical contradictions.
      #
      # @param transition [Hash] The transition rule to validate
      # @param actor [String] GAN identifier of the piece
      # @param origin [String] Source square
      # @param target [String] Destination square
      # @param index [Integer] Index of transition for error reporting
      #
      # @raise [ValidationError] If logical contradictions are found
      def validate_single_transition_logical_consistency!(transition, actor, origin, target, index)
        return unless transition.is_a?(::Hash)

        require_conditions = transition["require"]
        prevent_conditions = transition["prevent"]

        # Skip if either field is missing or not a hash
        return unless require_conditions.is_a?(::Hash) && prevent_conditions.is_a?(::Hash)

        # Find squares that appear in both require and prevent
        conflicting_squares = require_conditions.keys & prevent_conditions.keys

        # Check each conflicting square for state contradictions
        conflicting_squares.each do |square|
          required_state = require_conditions[square]
          prevented_state = prevent_conditions[square]

          # Logical contradiction: same state required and prevented
          if required_state == prevented_state
            raise ValidationError,
              "Logical contradiction detected in #{actor} from #{origin} to #{target} " \
              "(transition #{index}): square #{square} cannot simultaneously " \
              "require state '#{required_state}' and prevent state '#{prevented_state}'. " \
              "This creates an impossible condition that can never be satisfied."
          end
        end
      end
    end
  end
end
