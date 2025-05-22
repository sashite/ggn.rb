# frozen_string_literal: true

require_relative File.join("engine", "transition")

module Sashite
  module Ggn
    class Piece
      class Source
        class Destination
          # Evaluates pseudo-legal move conditions for a specific source-destination pair.
          #
          # The Engine is the core logic component that determines whether a move
          # is valid under the basic movement constraints defined in GGN. It evaluates
          # require/prevent conditions and returns the resulting board transformation.
          #
          # @example Evaluating a move
          #   engine = destinations.to('e4')
          #   result = engine.where(board_state, {}, 'CHESS')
          #   puts "Move valid!" if result
          class Engine
            # Reserved square identifier for piece drops from hand
            DROP_ORIGIN = "*"

            private_constant :DROP_ORIGIN

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

            # Evaluates move validity and returns the resulting transition.
            #
            # Checks each conditional transition in order until one matches the
            # current board state, or returns nil if no valid transition exists.
            #
            # @param board_state [Hash] Current board state mapping square labels
            #   to piece identifiers (nil for empty squares)
            # @param captures [Hash] Available pieces in hand (for drops)
            # @param turn [String] Current player's game identifier (e.g., 'CHESS', 'shogi')
            #
            # @return [Transition, nil] A Transition object if move is valid, nil otherwise
            #
            # @raise [ArgumentError] If any parameter is invalid or malformed
            #
            # @example Valid move evaluation
            #   board_state = { 'e2' => 'CHESS:P', 'e3' => nil, 'e4' => nil }
            #   result = engine.where(board_state, {}, 'CHESS')
            #   result.diff  # => { 'e2' => nil, 'e4' => 'CHESS:P' }
            #
            # @example Invalid move (blocked path)
            #   board_state = { 'e2' => 'CHESS:P', 'e3' => 'CHESS:N', 'e4' => nil }
            #   result = engine.where(board_state, {}, 'CHESS')  # => nil
            def where(board_state, captures, turn)
              validate_parameters!(board_state, captures, turn)

              return unless valid_move_context?(board_state, captures, turn)

              @transitions.each do |transition|
                next unless transition_matches?(transition, board_state, turn)

                return Transition.new(
                  transition["gain"],
                  transition["drop"],
                  **transition["perform"]
                )
              end

              nil
            end

            private

            # Validates all parameters in one consolidated method.
            #
            # @param board_state [Object] Should be a Hash
            # @param captures [Object] Should be a Hash
            # @param turn [Object] Should be a String
            #
            # @raise [ArgumentError] If any parameter is invalid
            def validate_parameters!(board_state, captures, turn)
              # Type validation
              unless board_state.is_a?(::Hash)
                raise ::ArgumentError, "board_state must be a Hash, got #{board_state.class}"
              end

              unless captures.is_a?(::Hash)
                raise ::ArgumentError, "captures must be a Hash, got #{captures.class}"
              end

              unless turn.is_a?(::String)
                raise ::ArgumentError, "turn must be a String, got #{turn.class}"
              end

              # Content validation
              validate_board_state!(board_state)
              validate_captures!(captures)
              validate_turn!(turn)
            end

            # Validates board_state structure and content.
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

            # Validates a square label.
            #
            # @param square [Object] Square label to validate
            #
            # @raise [ArgumentError] If square label is invalid
            def validate_square_label!(square)
              unless square.is_a?(::String) && !square.empty?
                raise ::ArgumentError, "Invalid square label: #{square.inspect}. Must be a non-empty String."
              end

              if square == DROP_ORIGIN
                raise ::ArgumentError, "Square label cannot be '#{DROP_ORIGIN}' (reserved for drops)."
              end
            end

            # Validates a piece on the board.
            #
            # @param piece [Object] Piece to validate
            # @param square [String] Square where piece is located
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

            # Validates turn format.
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

              if game_part == game_part.upcase
                base_letter == base_letter.upcase
              else
                base_letter == base_letter.downcase
              end
            end

            # Validates if a string is a valid base GAN identifier (no modifiers).
            #
            # @param identifier [String] Base GAN identifier to validate
            #
            # @return [Boolean] true if valid base GAN format
            def valid_base_gan_identifier?(identifier)
              return false unless identifier.include?(':')

              game_part, piece_part = identifier.split(':', 2)

              return false unless valid_game_identifier?(game_part)
              return false if piece_part.length != 1

              # Check casing consistency
              if game_part == game_part.upcase
                piece_part == piece_part.upcase && /\A[A-Z]\z/.match?(piece_part)
              else
                piece_part == piece_part.downcase && /\A[a-z]\z/.match?(piece_part)
              end
            end

            # Validates if a string is a valid game identifier.
            #
            # @param identifier [String] Game identifier to validate
            #
            # @return [Boolean] true if valid game identifier format
            def valid_game_identifier?(identifier)
              return false if identifier.empty?

              /\A([A-Z]+|[a-z]+)\z/.match?(identifier)
            end

            # Validates the move context before checking pseudo-legality.
            #
            # @param board_state [Hash] Current board state
            # @param captures [Hash] Available pieces in hand
            # @param turn [String] Current player's game identifier
            #
            # @return [Boolean] true if the move context is valid
            def valid_move_context?(board_state, captures, turn)
              if @origin == DROP_ORIGIN
                return false unless piece_available_in_hand?(captures)
              else
                return false unless piece_on_board_at_origin?(board_state)
              end

              piece_belongs_to_current_player?(turn)
            end

            # Checks if the piece is available in the player's hand for drop moves.
            #
            # @param captures [Hash] Available pieces in hand
            #
            # @return [Boolean] true if piece is available for dropping
            def piece_available_in_hand?(captures)
              base_piece = extract_base_piece(@actor)
              (captures[base_piece] || 0) > 0
            end

            # Checks if the piece is on the board at the origin square.
            #
            # @param board_state [Hash] Current board state
            #
            # @return [Boolean] true if the correct piece is at the origin
            def piece_on_board_at_origin?(board_state)
              board_state[@origin] == @actor
            end

            # Checks if the piece belongs to the current player.
            #
            # @param turn [String] Current player's game identifier
            #
            # @return [Boolean] true if piece belongs to current player
            def piece_belongs_to_current_player?(turn)
              return false unless @actor.include?(':')

              game_part = @actor.split(':', 2).fetch(0)
              piece_is_uppercase_player = game_part == game_part.upcase
              current_is_uppercase_player = turn == turn.upcase

              piece_is_uppercase_player == current_is_uppercase_player
            end

            # Extracts the base form of a piece (removes modifiers).
            #
            # @param actor [String] Full GAN identifier
            #
            # @return [String] Base form suitable for hand storage
            def extract_base_piece(actor)
              return actor unless actor.include?(':')

              game_part, piece_part = actor.split(':', 2)
              clean_piece = piece_part.gsub(/\A[-+]?([A-Za-z])'?\z/, '\1')

              "#{game_part}:#{clean_piece}"
            end

            # Checks if a transition matches the current board state.
            def transition_matches?(transition, board_state, turn)
              return false unless transition.is_a?(::Hash) && transition.key?("perform")
              return false if has_require_conditions?(transition) && !check_require_conditions(transition["require"], board_state, turn)
              return false if has_prevent_conditions?(transition) && !check_prevent_conditions(transition["prevent"], board_state, turn)

              true
            end

            # Checks if transition has require conditions.
            def has_require_conditions?(transition)
              transition["require"]&.is_a?(::Hash) && !transition["require"].empty?
            end

            # Checks if transition has prevent conditions.
            def has_prevent_conditions?(transition)
              transition["prevent"]&.is_a?(::Hash) && !transition["prevent"].empty?
            end

            # Verifies all require conditions are satisfied (logical AND).
            def check_require_conditions(require_conditions, board_state, turn)
              require_conditions.all? do |square, required_state|
                actual_piece = board_state[square]
                matches_state?(actual_piece, required_state, turn)
              end
            end

            # Verifies none of the prevent conditions are satisfied (logical NOR).
            def check_prevent_conditions(prevent_conditions, board_state, turn)
              prevent_conditions.none? do |square, forbidden_state|
                actual_piece = board_state[square]
                matches_state?(actual_piece, forbidden_state, turn)
              end
            end

            # Determines if a piece matches a required/forbidden state.
            def matches_state?(actual_piece, expected_state, turn)
              case expected_state
              when "empty"
                actual_piece.nil?
              when "enemy"
                actual_piece && enemy_piece?(actual_piece, turn)
              else
                actual_piece == expected_state
              end
            end

            # Determines if a piece belongs to the opposing player.
            def enemy_piece?(piece, turn)
              return false if piece.nil? || piece.empty?

              if piece.include?(':')
                game_part = piece.split(':', 2).fetch(0)
                piece_is_uppercase_player = game_part == game_part.upcase
                current_is_uppercase_player = turn == turn.upcase

                piece_is_uppercase_player != current_is_uppercase_player
              else
                # Fallback for non-GAN format
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
