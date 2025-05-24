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
          # The class uses a functional approach with filter_map for optimal performance
          # and clean, readable code that avoids mutation of external variables.
          #
          # @example Evaluating a move
          #   engine = destinations.to('e4')
          #   result = engine.where(board_state, {}, 'CHESS')
          #   puts "Move valid!" if result.any?
          class Engine
            include MoveValidator

            # Creates a new Engine with conditional transition rules.
            #
            # @param transitions [Array] Transition rules as individual arguments,
            #   each containing require/prevent conditions and perform actions.
            # @param actor [String] GAN identifier of the piece being moved
            # @param origin [String] Source square or "*" for drops
            # @param target [String] Destination square
            #
            # @raise [ArgumentError] If parameters are invalid
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
            # @param captures [Hash] Available pieces in hand (for drops)
            # @param turn [String] Current player's game identifier (e.g., 'CHESS', 'shogi')
            #
            # @return [Array<Transition>] Array of Transition objects for all valid variants,
            #   empty array if no valid transitions exist
            #
            # @raise [ArgumentError] If any parameter is invalid or malformed
            #
            # @example Single valid move
            #   board_state = { 'e2' => 'CHESS:P', 'e3' => nil, 'e4' => nil }
            #   results = engine.where(board_state, {}, 'CHESS')
            #   results.size  # => 1
            #   results.first.diff  # => { 'e2' => nil, 'e4' => 'CHESS:P' }
            #
            # @example Multiple promotion choices
            #   board_state = { 'e7' => 'CHESS:P', 'e8' => nil }
            #   results = engine.where(board_state, {}, 'CHESS')
            #   results.size  # => 4 (Queen, Rook, Bishop, Knight)
            #   results.map { |r| r.diff['e8'] }  # => ['CHESS:Q', 'CHESS:R', 'CHESS:B', 'CHESS:N']
            #
            # @example Invalid move (blocked path)
            #   board_state = { 'e2' => 'CHESS:P', 'e3' => 'CHESS:N', 'e4' => nil }
            #   results = engine.where(board_state, {}, 'CHESS')  # => []
            def where(board_state, captures, turn)
              # Validate all input parameters before processing
              validate_parameters!(board_state, captures, turn)

              # Early return if basic move context is invalid (wrong piece, not in hand, etc.)
              return [] unless valid_move_context?(board_state, captures, turn)

              # Use filter_map for functional approach: filter valid transitions and map to Transition objects
              # This avoids mutation and is more performant than select + map for large datasets
              @transitions.filter_map do |transition|
                # Only create Transition objects for transitions that match current board state
                create_transition(transition) if transition_matches?(transition, board_state, turn)
              end
            end

            private

            # Validates the move context before checking pseudo-legality.
            # Uses the shared MoveValidator module for consistency across the codebase.
            #
            # This method performs essential pre-checks:
            # - For drops: ensures the piece is available in hand
            # - For board moves: ensures the piece is at the expected origin square
            # - For all moves: ensures the piece belongs to the current player
            #
            # @param board_state [Hash] Current board state
            # @param captures [Hash] Available pieces in hand
            # @param turn [String] Current player's game identifier
            #
            # @return [Boolean] true if the move context is valid
            def valid_move_context?(board_state, captures, turn)
              # Check availability based on move type (drop vs regular move)
              if @origin == DROP_ORIGIN
                # For drops, piece must be available in player's hand
                return false unless piece_available_in_hand?(@actor, captures)
              else
                # For regular moves, piece must be on the board at origin square
                return false unless piece_on_board_at_origin?(@actor, @origin, board_state)
              end

              # Verify piece ownership - only current player can move their pieces
              piece_belongs_to_current_player?(@actor, turn)
            end

            # Creates a new Transition object from a transition rule.
            # Extracted to improve readability and maintainability of the main logic.
            #
            # @param transition [Hash] The transition rule containing gain, drop, and perform data
            #
            # @return [Transition] A new immutable Transition object
            def create_transition(transition)
              Transition.new(
                transition["gain"],
                transition["drop"],
                **transition["perform"]
              )
            end

            # Validates all parameters in one consolidated method.
            # Provides comprehensive validation with clear error messages for debugging.
            #
            # @param board_state [Object] Should be a Hash
            # @param captures [Object] Should be a Hash
            # @param turn [Object] Should be a String
            #
            # @raise [ArgumentError] If any parameter is invalid
            def validate_parameters!(board_state, captures, turn)
              # Type validation with clear error messages
              unless board_state.is_a?(::Hash)
                raise ::ArgumentError, "board_state must be a Hash, got #{board_state.class}"
              end

              unless captures.is_a?(::Hash)
                raise ::ArgumentError, "captures must be a Hash, got #{captures.class}"
              end

              unless turn.is_a?(::String)
                raise ::ArgumentError, "turn must be a String, got #{turn.class}"
              end

              # Content validation - ensures data integrity
              validate_board_state!(board_state)
              validate_captures!(captures)
              validate_turn!(turn)
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
            # Square labels must be non-empty strings and cannot conflict with reserved values.
            #
            # @param square [Object] Square label to validate
            #
            # @raise [ArgumentError] If square label is invalid
            def validate_square_label!(square)
              unless square.is_a?(::String) && !square.empty?
                raise ::ArgumentError, "Invalid square label: #{square.inspect}. Must be a non-empty String."
              end

              # Prevent conflicts with reserved drop origin marker
              if square == DROP_ORIGIN
                raise ::ArgumentError, "Square label cannot be '#{DROP_ORIGIN}' (reserved for drops)."
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

            # Validates captures structure and content.
            # Ensures piece identifiers are base form GAN and counts are non-negative integers.
            #
            # @param captures [Hash] Captures to validate
            #
            # @raise [ArgumentError] If captures contains invalid data
            def validate_captures!(captures)
              captures.each do |piece, count|
                validate_capture_piece!(piece)
                validate_capture_count!(count, piece)
              end
            end

            # Validates a piece identifier in captures.
            # Captured pieces must be in base form (no modifiers) according to FEEN specification.
            #
            # @param piece [Object] Piece identifier to validate
            #
            # @raise [ArgumentError] If piece identifier is invalid
            def validate_capture_piece!(piece)
              unless piece.is_a?(::String) && !piece.empty?
                raise ::ArgumentError, "Invalid piece identifier in captures: #{piece.inspect}. Must be a non-empty String."
              end

              unless valid_base_gan_identifier?(piece)
                raise ::ArgumentError, "Invalid base GAN identifier in captures: #{piece.inspect}. Must be base form GAN (e.g., 'CHESS:P', 'shogi:k') without modifiers."
              end
            end

            # Validates a capture count.
            # Counts must be non-negative integers representing available pieces.
            #
            # @param count [Object] Count to validate
            # @param piece [String] Associated piece for error context
            #
            # @raise [ArgumentError] If count is invalid
            def validate_capture_count!(count, piece)
              unless count.is_a?(::Integer) && count >= 0
                raise ::ArgumentError, "Invalid count for piece #{piece}: #{count.inspect}. Must be a non-negative Integer."
              end
            end

            # Validates turn format according to GAN specification.
            # Turn must be a non-empty alphabetic game identifier.
            #
            # @param turn [String] Turn identifier to validate
            #
            # @raise [ArgumentError] If turn format is invalid
            def validate_turn!(turn)
              if turn.empty?
                raise ::ArgumentError, "turn cannot be empty"
              end

              unless valid_game_identifier?(turn)
                raise ::ArgumentError, "Invalid turn format: #{turn.inspect}. Must be a valid game identifier (alphabetic characters only, e.g., 'CHESS', 'shogi')."
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

            # Validates if a string is a valid base GAN identifier (no modifiers).
            # Used for pieces in hand which cannot have state modifiers.
            #
            # @param identifier [String] Base GAN identifier to validate
            #
            # @return [Boolean] true if valid base GAN format
            def valid_base_gan_identifier?(identifier)
              return false unless identifier.include?(':')

              game_part, piece_part = identifier.split(':', 2)

              return false unless valid_game_identifier?(game_part)
              return false if piece_part.length != 1

              # Check casing consistency for base form
              if game_part == game_part.upcase
                piece_part == piece_part.upcase && /\A[A-Z]\z/.match?(piece_part)
              else
                piece_part == piece_part.downcase && /\A[a-z]\z/.match?(piece_part)
              end
            end

            # Validates if a string is a valid game identifier.
            # Game identifiers must be purely alphabetic (all upper or all lower case).
            #
            # @param identifier [String] Game identifier to validate
            #
            # @return [Boolean] true if valid game identifier format
            def valid_game_identifier?(identifier)
              return false if identifier.empty?

              /\A([A-Z]+|[a-z]+)\z/.match?(identifier)
            end

            # Checks if a transition matches the current board state.
            # Evaluates both require conditions (must be true) and prevent conditions (must be false).
            #
            # @param transition [Hash] The transition rule to evaluate
            # @param board_state [Hash] Current board state
            # @param turn [String] Current player identifier
            #
            # @return [Boolean] true if the transition is valid for current state
            def transition_matches?(transition, board_state, turn)
              # Ensure transition is properly formatted
              return false unless transition.is_a?(::Hash) && transition.key?("perform")

              # Check require conditions (all must be satisfied - logical AND)
              return false if has_require_conditions?(transition) && !check_require_conditions(transition["require"], board_state, turn)

              # Check prevent conditions (none must be satisfied - logical NOR)
              return false if has_prevent_conditions?(transition) && !check_prevent_conditions(transition["prevent"], board_state, turn)

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
            # @param turn [String] Current player identifier
            #
            # @return [Boolean] true if all conditions are satisfied
            def check_require_conditions(require_conditions, board_state, turn)
              require_conditions.all? do |square, required_state|
                actual_piece = board_state[square]
                matches_state?(actual_piece, required_state, turn)
              end
            end

            # Verifies none of the prevent conditions are satisfied (logical NOR).
            # If any prevent condition is true, the move is invalid.
            #
            # @param prevent_conditions [Hash] Square -> forbidden state mappings
            # @param board_state [Hash] Current board state
            # @param turn [String] Current player identifier
            #
            # @return [Boolean] true if no forbidden conditions are satisfied
            def check_prevent_conditions(prevent_conditions, board_state, turn)
              prevent_conditions.none? do |square, forbidden_state|
                actual_piece = board_state[square]
                matches_state?(actual_piece, forbidden_state, turn)
              end
            end

            # Determines if a piece matches a required/forbidden state.
            # Handles special states ("empty", "enemy") and exact piece matching.
            #
            # @param actual_piece [String, nil] The piece currently on the square
            # @param expected_state [String] The expected/forbidden state
            # @param turn [String] Current player identifier
            #
            # @return [Boolean] true if the piece matches the expected state
            def matches_state?(actual_piece, expected_state, turn)
              case expected_state
              when "empty"
                actual_piece.nil?
              when "enemy"
                actual_piece && enemy_piece?(actual_piece, turn)
              else
                # Exact piece match
                actual_piece == expected_state
              end
            end

            # Determines if a piece belongs to the opposing player.
            # Uses GAN casing conventions to determine ownership.
            #
            # @param piece [String] The piece identifier to check
            # @param turn [String] Current player identifier
            #
            # @return [Boolean] true if piece belongs to opponent
            def enemy_piece?(piece, turn)
              return false if piece.nil? || piece.empty?

              if piece.include?(':')
                # Use GAN format for ownership determination
                game_part = piece.split(':', 2).fetch(0)
                piece_is_uppercase_player = game_part == game_part.upcase
                current_is_uppercase_player = turn == turn.upcase

                # Enemy if players have different casing
                piece_is_uppercase_player != current_is_uppercase_player
              else
                # Fallback for non-GAN format (legacy support)
                piece_is_uppercase = piece == piece.upcase
                current_is_uppercase = turn == turn.upcase

                piece_is_uppercase != current_is_uppercase
              end
            end
          end
        end
      end
    end
  end
end
