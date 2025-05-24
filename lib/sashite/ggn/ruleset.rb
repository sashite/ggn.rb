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
    #   captures = { 'CHESS:P' => 2 }
    #   all_moves = piece_data.pseudo_legal_transitions(board_state, captures, 'CHESS')
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
      #
      # @raise [ArgumentError] If data is not a Hash
      #
      # @example Creating from parsed JSON data
      #   ggn_data = JSON.parse(File.read('chess.json'))
      #   ruleset = Ruleset.new(ggn_data)
      def initialize(data)
        raise ::ArgumentError, "Expected Hash, got #{data.class}" unless data.is_a?(::Hash)

        @data = data

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
        Source.new(data, actor:)
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
      # @param captures [Hash] Available pieces in hand for drops
      # @param turn [String] Current player's game identifier (e.g., 'CHESS', 'shogi')
      #
      # @return [Array<Array>] List of move transitions, where each element is:
      #   [actor, origin, target, transitions]
      #   - actor [String]: GAN identifier of the moving piece
      #   - origin [String]: Source square or "*" for drops
      #   - target [String]: Destination square
      #   - transitions [Array<Transition>]: All valid transition variants
      #
      # @raise [ArgumentError] If any parameter is invalid or malformed
      #
      # @example Getting all possible transitions including promotion variants
      #   board_state = { 'e7' => 'CHESS:P', 'e8' => nil }
      #   transitions = piece_data.pseudo_legal_transitions(board_state, {}, 'CHESS')
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
      #   transitions = piece_data.pseudo_legal_transitions(board_state, captures, 'CHESS')
      #   transitions.each do |actor, origin, target, variants|
      #     puts "#{actor} from #{origin} to #{target}:"
      #     variants.each_with_index do |transition, i|
      #       puts "  Variant #{i + 1}: #{transition.diff}"
      #       puts "    Gain: #{transition.gain}" if transition.gain?
      #       puts "    Drop: #{transition.drop}" if transition.drop?
      #     end
      #   end
      #
      # @example Filtering for specific move types
      #   # Find all capture moves
      #   captures_only = piece_data.pseudo_legal_transitions(board_state, captures, turn)
      #     .select { |actor, origin, target, variants| variants.any?(&:gain?) }
      #
      #   # Find all drop moves
      #   drops_only = piece_data.pseudo_legal_transitions(board_state, captures, turn)
      #     .select { |actor, origin, target, variants| origin == "*" }
      #
      # @example Performance considerations
      #   # For large datasets, consider filtering by piece type first
      #   specific_piece_moves = piece_data.select('CHESS:Q')
      #     .from('d1').to('d8').where(board_state, captures, turn)
      def pseudo_legal_transitions(board_state, captures, turn)
        validate_pseudo_legal_parameters!(board_state, captures, turn)

        # Use flat_map to process all actors and flatten the results in one pass
        # This functional approach avoids mutation and intermediate arrays
        @data.flat_map do |actor, source_data|
          # Early filter: only process pieces belonging to current player
          # This optimization significantly reduces processing time
          next [] unless piece_belongs_to_current_player?(actor, turn)

          # Process all source positions for this actor using functional decomposition
          process_actor_transitions(actor, source_data, board_state, captures, turn)
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
      # @param captures [Hash] Available pieces in hand
      # @param turn [String] Current player identifier
      #
      # @return [Array] Array of valid transition tuples for this actor
      #
      # @example Source data structure
      #   {
      #     "e1" => { "e2" => [...], "f1" => [...] },  # Regular moves
      #     "*"  => { "e4" => [...], "f5" => [...] }   # Drop moves
      #   }
      def process_actor_transitions(actor, source_data, board_state, captures, turn)
        source_data.flat_map do |origin, destination_data|
          # Early filter: check movement context (piece availability/position)
          # For drops: piece must be available in hand
          # For moves: piece must be present at origin square
          next [] unless valid_movement_context?(actor, origin, board_state, captures)

          # Process all destination squares for this origin
          process_origin_transitions(actor, origin, destination_data, board_state, captures, turn)
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
      # @param origin [String] Source square or "*" for drops
      # @param destination_data [Hash] Available destinations and their transition rules
      # @param board_state [Hash] Current board state
      # @param captures [Hash] Available pieces in hand
      # @param turn [String] Current player identifier
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
      def process_origin_transitions(actor, origin, destination_data, board_state, captures, turn)
        destination_data.filter_map do |target, transition_rules|
          # Create engine to evaluate this specific source-destination pair
          # Each engine encapsulates the conditional logic for one move
          engine = Source::Destination::Engine.new(*transition_rules, actor: actor, origin: origin, target: target)

          # Get all valid transitions for this move (supports multiple variants)
          # The engine handles require/prevent conditions and returns Transition objects
          transitions = engine.where(board_state, captures, turn)

          # Only return successful moves (with at least one valid transition)
          # filter_map automatically filters out nil values
          [actor, origin, target, transitions] unless transitions.empty?
        end
      end

      # Validates movement context based on origin type.
      #
      # This method centralizes the logic for checking piece availability and position,
      # providing a clean abstraction over the different requirements for drops vs moves.
      # Uses the shared MoveValidator module for consistency across the codebase.
      #
      # @param actor [String] GAN identifier of the piece
      # @param origin [String] Source square or "*" for drops
      # @param board_state [Hash] Current board state
      # @param captures [Hash] Available pieces in hand
      #
      # @return [Boolean] true if the movement context is valid
      #
      # @example Drop move validation
      #   valid_movement_context?("SHOGI:P", "*", board_state, {"SHOGI:P" => 1})
      #   # => true (pawn available in hand)
      #
      # @example Regular move validation
      #   valid_movement_context?("CHESS:K", "e1", {"e1" => "CHESS:K"}, {})
      #   # => true (king present at e1)
      def valid_movement_context?(actor, origin, board_state, captures)
        if origin == DROP_ORIGIN
          # For drops: piece must be available in hand
          # Uses base form of piece identifier (without modifiers)
          piece_available_in_hand?(actor, captures)
        else
          # For regular moves: piece must be on board at origin
          # Ensures the exact piece is at the expected position
          piece_on_board_at_origin?(actor, origin, board_state)
        end
      end

      # Validates parameters for pseudo_legal_transitions method.
      #
      # Provides comprehensive validation with clear error messages for debugging.
      # This method ensures data integrity and helps catch common usage errors
      # early in the processing pipeline.
      #
      # @param board_state [Object] Should be a Hash mapping squares to pieces
      # @param captures [Object] Should be a Hash mapping piece types to counts
      # @param turn [Object] Should be a String representing current player
      #
      # @raise [ArgumentError] If any parameter is invalid
      #
      # @example Valid parameters
      #   validate_pseudo_legal_parameters!(
      #     { "e1" => "CHESS:K", "e2" => nil },
      #     { "CHESS:P" => 2 },
      #     "CHESS"
      #   )
      #
      # @example Invalid parameters (raises ArgumentError)
      #   validate_pseudo_legal_parameters!("invalid", {}, "CHESS")
      #   validate_pseudo_legal_parameters!({}, "invalid", "CHESS")
      #   validate_pseudo_legal_parameters!({}, {}, 123)
      #   validate_pseudo_legal_parameters!({}, {}, "")
      def validate_pseudo_legal_parameters!(board_state, captures, turn)
        # Type validation with clear, specific error messages
        unless board_state.is_a?(::Hash)
          raise ::ArgumentError, "board_state must be a Hash, got #{board_state.class}"
        end

        unless captures.is_a?(::Hash)
          raise ::ArgumentError, "captures must be a Hash, got #{captures.class}"
        end

        unless turn.is_a?(::String)
          raise ::ArgumentError, "turn must be a String, got #{turn.class}"
        end

        # Content validation - ensures meaningful data
        if turn.empty?
          raise ::ArgumentError, "turn cannot be empty"
        end

        # Validate board_state structure (optional deep validation)
        validate_board_state_structure!(board_state) if ENV['GGN_STRICT_VALIDATION']

        # Validate captures structure (optional deep validation)
        validate_captures_structure!(captures) if ENV['GGN_STRICT_VALIDATION']
      end

      # Validates board_state structure in strict mode.
      #
      # This optional validation can be enabled via environment variable
      # to catch malformed board states during development and testing.
      #
      # @param board_state [Hash] Board state to validate
      #
      # @raise [ArgumentError] If board_state contains invalid data
      def validate_board_state_structure!(board_state)
        board_state.each do |square, piece|
          unless square.is_a?(::String) && !square.empty?
            raise ::ArgumentError, "Invalid square label: #{square.inspect}"
          end

          if piece && (!piece.is_a?(::String) || piece.empty?)
            raise ::ArgumentError, "Invalid piece at #{square}: #{piece.inspect}"
          end
        end
      end

      # Validates captures structure in strict mode.
      #
      # This optional validation ensures that capture data follows
      # the expected format with proper piece identifiers and counts.
      #
      # @param captures [Hash] Captures to validate
      #
      # @raise [ArgumentError] If captures contains invalid data
      def validate_captures_structure!(captures)
        captures.each do |piece, count|
          unless piece.is_a?(::String) && !piece.empty?
            raise ::ArgumentError, "Invalid piece in captures: #{piece.inspect}"
          end

          unless count.is_a?(::Integer) && count >= 0
            raise ::ArgumentError, "Invalid count for #{piece}: #{count.inspect}"
          end
        end
      end
    end
  end
end
