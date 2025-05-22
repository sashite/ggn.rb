# frozen_string_literal: true

require_relative File.join("piece", "source")

module Sashite
  module Ggn
    # Represents a collection of piece definitions from a GGN document.
    #
    # A Piece instance contains all the pseudo-legal move definitions for
    # various game pieces, organized by their GAN (General Actor Notation)
    # identifiers. This class provides the entry point for querying specific
    # piece movement rules.
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
    # @see https://sashite.dev/documents/gan/ GAN Specification
    class Piece
      # Creates a new Piece instance from GGN data.
      #
      # @param data [Hash] The parsed GGN JSON data structure, where keys are
      #   GAN identifiers and values contain the movement definitions.
      #
      # @raise [ArgumentError] If data is not a Hash
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
    end
  end
end
