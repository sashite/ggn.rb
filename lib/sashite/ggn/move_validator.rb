# frozen_string_literal: true

module Sashite
  module Ggn
    # Centralized module for move condition validation.
    # Contains shared logic between Engine and performance optimizations.
    module MoveValidator
      # Reserved for drops from hand
      DROP_ORIGIN = "*"

      # Separator in GAN (General Actor Notation) identifiers
      GAN_SEPARATOR = ":"

      private_constant :DROP_ORIGIN, :GAN_SEPARATOR

      private

      # Checks if the piece is available in hand for a drop move.
      #
      # @param actor [String] GAN identifier of the piece
      # @param captures [Hash] Pieces available in hand
      #
      # @return [Boolean] true if the piece can be dropped
      def piece_available_in_hand?(actor, captures)
        return false unless valid_gan_format?(actor)

        base_piece = extract_base_piece(actor)
        return false if base_piece.nil?

        (captures[base_piece] || 0) > 0
      end

      # Checks if the correct piece is present at the origin square on the board.
      #
      # @param actor [String] GAN identifier of the piece
      # @param origin [String] Origin square
      # @param board_state [Hash] Current board state
      #
      # @return [Boolean] true if the piece is at the correct position
      def piece_on_board_at_origin?(actor, origin, board_state)
        return false unless valid_gan_format?(actor)
        return false unless origin.is_a?(String) && !origin.empty?
        return false unless board_state.is_a?(Hash)

        board_state[origin] == actor
      end

      # Checks if the piece belongs to the current player.
      # Fixed version that verifies both the game name AND the case.
      #
      # This method now performs strict validation by ensuring:
      # - The game identifier matches exactly with the turn parameter
      # - The case convention is consistent (uppercase/lowercase players)
      # - The piece part follows the same case convention as the game part
      #
      # @param actor [String] GAN identifier of the piece
      # @param turn [String] Current player's game identifier
      #
      # @return [Boolean] true if the piece belongs to the current player
      def piece_belongs_to_current_player?(actor, turn)
        return false unless valid_gan_format?(actor)
        return false unless valid_game_identifier?(turn)

        game_part, piece_part = actor.split(GAN_SEPARATOR, 2)

        # Strict verification: the game name must match exactly
        # while considering case to determine the player
        case turn
        when turn.upcase
          # Current player is the uppercase one
          game_part == turn && game_part == game_part.upcase && piece_part.match?(/\A[-+]?[A-Z][']?\z/)
        when turn.downcase
          # Current player is the lowercase one
          game_part == turn && game_part == game_part.downcase && piece_part.match?(/\A[-+]?[a-z][']?\z/)
        else
          # Turn is neither entirely uppercase nor lowercase
          false
        end
      end

      # Extracts the base form of a piece (removes modifiers).
      #
      # According to FEEN specification, pieces in hand are always stored
      # in their base form without any state modifiers (prefixes/suffixes).
      #
      # @param actor [String] Complete GAN identifier
      #
      # @return [String, nil] Base form for hand storage, nil if invalid format
      def extract_base_piece(actor)
        return nil unless valid_gan_format?(actor)

        game_part, piece_part = actor.split(GAN_SEPARATOR, 2)

        # Safe extraction of the base character
        match = piece_part.match(/\A[-+]?([A-Za-z])[']?\z/)
        return nil unless match

        clean_piece = match[1]

        # Case consistency verification
        game_is_upper = game_part == game_part.upcase
        piece_is_upper = clean_piece == clean_piece.upcase

        return nil unless game_is_upper == piece_is_upper

        "#{game_part}#{GAN_SEPARATOR}#{clean_piece}"
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
        piece_match = piece_part.match(/\A[-+]?([A-Za-z])[']?\z/)
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
      def valid_piece_identifier?(piece_id)
        return false unless piece_id.is_a?(String)
        return false if piece_id.empty?

        # Format: [optional prefix][letter][optional suffix]
        piece_id.match?(/\A[-+]?[A-Za-z][']?\z/)
      end
    end
  end
end
