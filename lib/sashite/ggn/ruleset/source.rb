# frozen_string_literal: true

require_relative File.join("..", "move_validator")
require_relative File.join("source", "destination")

module Sashite
  module Ggn
    class Ruleset
      # Represents the possible source positions for a specific piece type.
      #
      # A Source instance contains all the starting positions from which
      # a piece can move on the board. Since GGN focuses exclusively on
      # board-to-board transformations, all source positions are regular
      # board squares.
      #
      # @example Basic usage with chess king
      #   piece_data = Sashite::Ggn.load_file('chess.json')
      #   source = piece_data.select('CHESS:K')
      #   destinations = source.from('e1')
      #
      # @example Complete move evaluation workflow
      #   piece_data = Sashite::Ggn.load_file('chess.json')
      #   king_source = piece_data.select('CHESS:K')
      #   destinations = king_source.from('e1')
      #   engine = destinations.to('e2')
      #
      #   board_state = { 'e1' => 'CHESS:K', 'e2' => nil }
      #   transitions = engine.where(board_state, 'CHESS')
      #
      #   if transitions.any?
      #     puts "King can move from e1 to e2"
      #   end
      class Source
        include MoveValidator

        # Creates a new Source instance from movement data.
        #
        # @param data [Hash] The movement data where keys are source positions
        #   (square labels) and values contain destination data.
        # @param actor [String] The GAN identifier for this piece type
        #
        # @raise [ArgumentError] If data is not a Hash
        #
        # @example Creating a Source instance
        #   source_data = {
        #     "e1" => { "e2" => [...], "f1" => [...] },
        #     "d4" => { "d5" => [...], "e5" => [...] }
        #   }
        #   source = Source.new(source_data, actor: "CHESS:K")
        def initialize(data, actor:)
          raise ::ArgumentError, "Expected Hash, got #{data.class}" unless data.is_a?(::Hash)

          @data = data
          @actor = actor

          freeze
        end

        # Retrieves possible destinations from a specific source position.
        #
        # @param origin [String] The source position label. Must be a regular
        #   square label (e.g., 'e1', '5i', 'a1').
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
        # @example Handling missing origins
        #   begin
        #     destinations = source.from('invalid_square')
        #   rescue KeyError => e
        #     puts "No moves from this position: #{e.message}"
        #   end
        #
        # @example Iterating through all possible origins
        #   # Assuming you have access to the source data keys
        #   available_origins = ['e1', 'd1', 'f1']  # example origins
        #   available_origins.each do |pos|
        #     begin
        #       destinations = source.from(pos)
        #       puts "Piece can move from #{pos}"
        #       # Process destinations...
        #     rescue KeyError
        #       puts "No moves available from #{pos}"
        #     end
        #   end
        def from(origin)
          data = @data.fetch(origin)
          Destination.new(data, actor: @actor, origin: origin)
        end
      end
    end
  end
end
