# frozen_string_literal: true

require_relative File.join("destination", "engine")

module Sashite
  module Ggn
    class Piece
      class Source
        # Represents the possible destination squares for a piece from a specific source.
        #
        # A Destination instance contains all the target squares a piece can reach
        # from a given starting position, along with the conditional rules that
        # govern each potential move.
        #
        # @example Basic usage
        #   destinations = source.from('e1')
        #   engine = destinations.to('e2')
        #   result = engine.evaluate(board_state, captures, current_player)
        class Destination
          # Creates a new Destination instance from target square data.
          #
          # @param data [Hash] The destination data where keys are target square
          #   labels and values are arrays of conditional transition rules.
          # @param actor [String] The GAN identifier for this piece type
          # @param origin [String] The source position
          #
          # @raise [ArgumentError] If data is not a Hash
          def initialize(data, actor:, origin:)
            raise ::ArgumentError, "Expected Hash, got #{data.class}" unless data.is_a?(::Hash)

            @data = data
            @actor = actor
            @origin = origin

            freeze
          end

          # Retrieves the movement engine for a specific target square.
          #
          # @param target [String] The destination square label (e.g., 'e2', '5h').
          #
          # @return [Engine] An Engine instance that can evaluate whether the move
          #   to this target is valid given current board conditions.
          #
          # @raise [KeyError] If the target square is not reachable from the source
          #
          # @example Getting movement rules to a specific square
          #   engine = destinations.to('e2')
          #   result = engine.evaluate(board_state, captures, current_player)
          #
          # @example Handling unreachable targets
          #   begin
          #     engine = destinations.to('invalid_square')
          #   rescue KeyError => e
          #     puts "Cannot move to this square: #{e.message}"
          #   end
          def to(target)
            transitions = @data.fetch(target)
            Engine.new(*transitions, actor: @actor, origin: @origin, target:)
          end
        end
      end
    end
  end
end
