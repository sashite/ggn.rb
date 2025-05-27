# frozen_string_literal: true

module Sashite
  module Ggn
    # Centralized module for move condition validation.
    # Contains shared logic for validating piece ownership and board positions
    # in GGN move evaluation.
    #
    # This module focuses exclusively on board-based validation since GGN
    # only handles board-to-board transformations. All methods work with
    # pieces on the board and use GAN (General Actor Notation) identifiers.
    module MoveValidator
      # Separator in GAN (General Actor Notation) identifiers.
      # Used to split game identifiers from piece identifiers.
      #
      # @example GAN format
      #   "CHESS:K"  # game: "CHESS", piece: "K"
      #   "shogi:+p" # game: "shogi", piece: "+p"
      GAN_SEPARATOR = ":"

      private

      # Checks if the correct piece is present at the origin square on the board.
      #
      # This method validates that the expected piece is actually present at the
      # specified origin square, which is a fundamental requirement for any move.
      #
      # @param actor [String] GAN identifier of the piece
      # @param origin [String] Origin square
      # @param board_state [Hash] Current board state
      #
      # @return [Boolean] true if the piece is at the correct position
      #
      # @example Valid piece placement
      #   board_state = { "e1" => "CHESS:K", "e2" => "CHESS:P" }
      #   piece_on_board_at_origin?("CHESS:K", "e1", board_state)
      #   # => true
      #
      # @example Invalid piece placement
      #   board_state = { "e1" => "CHESS:Q", "e2" => "CHESS:P" }
      #   piece_on_board_at_origin?("CHESS:K", "e1", board_state)
      #   # => false (wrong piece at e1)
      #
      # @example Empty square
      #   board_state = { "e1" => nil, "e2" => "CHESS:P" }
      #   piece_on_board_at_origin?("CHESS:K", "e1", board_state)
      #   # => false (no piece at e1)
      def piece_on_board_at_origin?(actor, origin, board_state)
        return false unless valid_gan_format?(actor)
        return false unless origin.is_a?(String) && !origin.empty?
        return false unless board_state.is_a?(Hash)

        board_state[origin] == actor
      end

      # Checks if the piece belongs to the current player based on case matching.
      #
      # This method implements the corrected ownership logic based on FEEN specification:
      # - Ownership is determined by case correspondence, not exact string matching
      # - If active_game is uppercase, the player owns uppercase-cased pieces
      # - If active_game is lowercase, the player owns lowercase-cased pieces
      # - This allows for hybrid games where a player may control pieces from different games
      #
      # @param actor [String] GAN identifier of the piece
      # @param active_game [String] Current player's game identifier
      #
      # @return [Boolean] true if the piece belongs to the current player
      #
      # @example Same game, same case (typical scenario)
      #   piece_belongs_to_current_player?("CHESS:K", "CHESS")
      #   # => true (both uppercase)
      #
      # @example Different games, same case (hybrid scenario)
      #   piece_belongs_to_current_player?("MAKRUK:K", "CHESS")
      #   # => true (both uppercase, player controls both)
      #
      # @example Same game, different case
      #   piece_belongs_to_current_player?("chess:k", "CHESS")
      #   # => false (different players)
      #
      # @example Mixed case active_game (invalid)
      #   piece_belongs_to_current_player?("CHESS:K", "Chess")
      #   # => false (invalid active_game format)
      def piece_belongs_to_current_player?(actor, active_game)
        return false unless valid_gan_format?(actor)
        return false unless valid_game_identifier?(active_game)

        game_part, piece_part = actor.split(GAN_SEPARATOR, 2)

        # Determine player ownership based on case correspondence
        # If active_game is uppercase, player owns uppercase pieces
        # If active_game is lowercase, player owns lowercase pieces
        case active_game
        when active_game.upcase
          # Current player is the uppercase one
          game_part == game_part.upcase && piece_part.match?(/\A[-+]?[A-Z]'?\z/)
        when active_game.downcase
          # Current player is the lowercase one
          game_part == game_part.downcase && piece_part.match?(/\A[-+]?[a-z]'?\z/)
        else
          # active_game is neither entirely uppercase nor lowercase
          false
        end
      end

      # Validates the GAN format of an identifier.
      #
      # A valid GAN identifier must:
      # - Be a string containing exactly one colon separator
      # - Have a valid game identifier before the colon
      # - Have a valid piece identifier after the colon
      # - Maintain case consistency between game and piece parts
      #
      # @param actor [String] Identifier to validate
      #
      # @return [Boolean] true if the format is valid
      #
      # @example Valid GAN identifiers
      #   valid_gan_format?("CHESS:K")     # => true
      #   valid_gan_format?("shogi:+p")    # => true
      #   valid_gan_format?("MAKRUK:R'")   # => true
      #
      # @example Invalid GAN identifiers
      #   valid_gan_format?("CHESS")       # => false (no colon)
      #   valid_gan_format?("chess:K")     # => false (case mismatch)
      #   valid_gan_format?("CHESS:")      # => false (no piece part)
      def valid_gan_format?(actor)
        return false unless actor.is_a?(String)
        return false unless actor.include?(GAN_SEPARATOR)

        parts = actor.split(GAN_SEPARATOR, 2)
        return false unless parts.length == 2

        game_part, piece_part = parts

        return false unless valid_game_identifier?(game_part)
        return false unless valid_piece_identifier?(piece_part)

        # Case consistency verification between game and piece
        game_is_upper = game_part == game_part.upcase
        piece_match = piece_part.match(/\A[-+]?([A-Za-z])'?\z/)
        return false unless piece_match

        piece_char = piece_match[1]
        piece_is_upper = piece_char == piece_char.upcase

        game_is_upper == piece_is_upper
      end

      # Validates a game identifier.
      #
      # Game identifiers must be non-empty strings containing only
      # alphabetic characters, either all uppercase or all lowercase.
      # Mixed case is not allowed as it breaks the player distinction.
      #
      # @param game_id [String] Game identifier to validate
      #
      # @return [Boolean] true if the identifier is valid
      #
      # @example Valid game identifiers
      #   valid_game_identifier?("CHESS")   # => true
      #   valid_game_identifier?("shogi")   # => true
      #   valid_game_identifier?("XIANGQI") # => true
      #
      # @example Invalid game identifiers
      #   valid_game_identifier?("Chess")   # => false (mixed case)
      #   valid_game_identifier?("")        # => false (empty)
      #   valid_game_identifier?("CHESS1")  # => false (contains digit)
      def valid_game_identifier?(game_id)
        return false unless game_id.is_a?(String)
        return false if game_id.empty?

        # Must be either entirely uppercase or entirely lowercase
        game_id.match?(/\A[A-Z]+\z/) || game_id.match?(/\A[a-z]+\z/)
      end

      # Validates a piece identifier (part after the colon).
      #
      # Piece identifiers follow the pattern: [optional prefix][letter][optional suffix]
      # Where:
      # - Optional prefix: + or -
      # - Letter: A-Z or a-z (must match game part case)
      # - Optional suffix: ' (apostrophe)
      #
      # @param piece_id [String] Piece identifier to validate
      #
      # @return [Boolean] true if the identifier is valid
      #
      # @example Valid piece identifiers
      #   valid_piece_identifier?("K")      # => true
      #   valid_piece_identifier?("+p")     # => true
      #   valid_piece_identifier?("R'")     # => true
      #   valid_piece_identifier?("-Q'")    # => true
      #
      # @example Invalid piece identifiers
      #   valid_piece_identifier?("")       # => false (empty)
      #   valid_piece_identifier?("++K")    # => false (double prefix)
      #   valid_piece_identifier?("K''")    # => false (double suffix)
      def valid_piece_identifier?(piece_id)
        return false unless piece_id.is_a?(String)
        return false if piece_id.empty?

        # Format: [optional prefix][letter][optional suffix]
        piece_id.match?(/\A[-+]?[A-Za-z]'?\z/)
      end
    end
  end
end
