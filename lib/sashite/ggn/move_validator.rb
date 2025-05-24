# frozen_string_literal: true

module Sashite
  module Ggn
    # Module centralisé pour la validation des conditions de mouvement.
    # Contient la logique partagée entre Engine et les optimisations de performance.
    module MoveValidator
      # Réservé pour les drops depuis la main
      DROP_ORIGIN = "*"

      private_constant :DROP_ORIGIN

      private

      # Vérifie si la pièce est disponible en main pour un drop.
      #
      # @param actor [String] Identifiant GAN de la pièce
      # @param captures [Hash] Pièces disponibles en main
      #
      # @return [Boolean] true si la pièce peut être droppée
      def piece_available_in_hand?(actor, captures)
        base_piece = extract_base_piece(actor)
        (captures[base_piece] || 0) > 0
      end

      # Vérifie si la pièce correcte est présente à l'origine sur le plateau.
      #
      # @param actor [String] Identifiant GAN de la pièce
      # @param origin [String] Case d'origine
      # @param board_state [Hash] État actuel du plateau
      #
      # @return [Boolean] true si la pièce est à la bonne position
      def piece_on_board_at_origin?(actor, origin, board_state)
        board_state[origin] == actor
      end

      # Vérifie si la pièce appartient au joueur actuel.
      #
      # @param actor [String] Identifiant GAN de la pièce
      # @param turn [String] Identifiant du joueur actuel
      #
      # @return [Boolean] true si la pièce appartient au joueur actuel
      def piece_belongs_to_current_player?(actor, turn)
        return false unless actor.include?(':')

        game_part = actor.split(':', 2).fetch(0)
        piece_is_uppercase_player = game_part == game_part.upcase
        current_is_uppercase_player = turn == turn.upcase

        piece_is_uppercase_player == current_is_uppercase_player
      end

      # Extrait la forme de base d'une pièce (supprime les modificateurs).
      #
      # @param actor [String] Identifiant GAN complet
      #
      # @return [String] Forme de base pour le stockage en main
      def extract_base_piece(actor)
        return actor unless actor.include?(':')

        game_part, piece_part = actor.split(':', 2)
        clean_piece = piece_part.gsub(/\A[-+]?([A-Za-z])'?\z/, '\1')

        "#{game_part}:#{clean_piece}"
      end
    end
  end
end
