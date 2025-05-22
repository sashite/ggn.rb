# frozen_string_literal: true

require_relative File.join("source", "destination")

module Sashite
  module Ggn
    class Piece
      # Represents the possible source positions for a specific piece type.
      #
      # A Source instance contains all the starting positions from which
      # a piece can move, including regular board squares and special
      # positions like "*" for piece drops from hand.
      #
      # @example Basic usage with chess king
      #   piece_data = Sashite::Ggn.load_file('chess.json')
      #   source = piece_data.select('CHESS:K')
      #   destinations = source.from('e1')
      #
      # @example Usage with Shogi pawn drops
      #   piece_data = Sashite::Ggn.load_file('shogi.json')
      #   pawn_source = piece_data.select('SHOGI:P')
      #   drop_destinations = pawn_source.from('*')  # For piece drops from hand
      class Source
        # Creates a new Source instance from movement data.
        #
        # @param data [Hash] The movement data where keys are source positions
        #   (square labels or "*" for drops) and values contain destination data.
        # @param actor [String] The GAN identifier for this piece type
        #
        # @raise [ArgumentError] If data is not a Hash
        def initialize(data, actor:)
          raise ::ArgumentError, "Expected Hash, got #{data.class}" unless data.is_a?(::Hash)

          @data = data
          @actor = actor

          freeze
        end

        # Retrieves possible destinations from a specific source position.
        #
        # @param origin [String] The source position label. Can be a regular
        #   square label (e.g., 'e1', '5i') or "*" for piece drops from hand.
        #
        # @return [Destination] A Destination instance containing all possible
        #   target squares and their movement conditions from this origin.
        #
        # @raise [KeyError] If the origin position is not found in the data
        #
        # @example Getting moves from a specific square
        #   destinations = source.from('e1')
        #   engine = destinations.to('e2')
        #
        # @example Getting drop moves (for games like Shogi)
        #   drop_destinations = source.from('*')
        #   engine = drop_destinations.to('5e')
        #
        # @example Handling missing origins
        #   begin
        #     destinations = source.from('invalid_square')
        #   rescue KeyError => e
        #     puts "No moves from this position: #{e.message}"
        #   end
        def from(origin)
          data = @data.fetch(origin)
          Destination.new(data, actor: @actor, origin:)
        end
      end
    end
  end
end
