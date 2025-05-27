# frozen_string_literal: true

require_relative File.join("destination", "engine")

module Sashite
  module Ggn
    class Ruleset
      class Source
        # Represents the possible destination squares for a piece from a specific source.
        #
        # A Destination instance contains all the target squares a piece can reach
        # from a given starting position, along with the conditional rules that
        # govern each potential move. Since GGN focuses exclusively on board-to-board
        # transformations, all destinations represent squares on the game board.
        #
        # @example Basic usage
        #   destinations = source.from('e1')
        #   engine = destinations.to('e2')
        #   transitions = engine.where(board_state, 'CHESS')
        #
        # @example Exploring all possible destinations
        #   destinations = source.from('e1')
        #   # destinations.to('e2') - one square forward
        #   # destinations.to('f1') - one square right
        #   # destinations.to('d1') - one square left
        #   # Each destination has its own movement rules and conditions
        class Destination
          # Creates a new Destination instance from target square data.
          #
          # @param data [Hash] The destination data where keys are target square
          #   labels and values are arrays of conditional transition rules.
          # @param actor [String] The GAN identifier for this piece type
          # @param origin [String] The source position
          #
          # @raise [ArgumentError] If data is not a Hash
          #
          # @example Creating a Destination instance
          #   destination_data = {
          #     "e2" => [
          #       { "require" => { "e2" => "empty" }, "perform" => { "e1" => nil, "e2" => "CHESS:K" } }
          #     ],
          #     "f1" => [
          #       { "require" => { "f1" => "empty" }, "perform" => { "e1" => nil, "f1" => "CHESS:K" } }
          #     ]
          #   }
          #   destination = Destination.new(destination_data, actor: "CHESS:K", origin: "e1")
          def initialize(data, actor:, origin:)
            raise ::ArgumentError, "Expected Hash, got #{data.class}" unless data.is_a?(::Hash)

            @data = data
            @actor = actor
            @origin = origin

            freeze
          end

          # Retrieves the movement engine for a specific target square.
          #
          # This method creates an Engine instance that can evaluate whether the move
          # to the specified target square is valid given the current board conditions.
          # The engine encapsulates all the conditional logic (require/prevent/perform)
          # for this specific source-to-destination move.
          #
          # @param target [String] The destination square label (e.g., 'e2', '5h', 'a8').
          #
          # @return [Engine] An Engine instance that can evaluate move validity
          #   and return all possible transition variants for this move.
          #
          # @raise [KeyError] If the target square is not reachable from the source
          #
          # @example Getting movement rules to a specific square
          #   engine = destinations.to('e2')
          #   transitions = engine.where(board_state, 'CHESS')
          #
          #   if transitions.any?
          #     puts "Move is valid!"
          #     transitions.each { |t| puts "Result: #{t.diff}" }
          #   else
          #     puts "Move is not valid under current conditions"
          #   end
          #
          # @example Handling unreachable targets
          #   begin
          #     engine = destinations.to('invalid_square')
          #   rescue KeyError => e
          #     puts "Cannot move to this square: #{e.message}"
          #   end
          #
          # @example Testing multiple destinations
          #   ['e2', 'f1', 'd1'].each do |target|
          #     begin
          #       engine = destinations.to(target)
          #       transitions = engine.where(board_state, 'CHESS')
          #       puts "#{target}: #{transitions.size} possible transitions"
          #     rescue KeyError
          #       puts "#{target}: not reachable"
          #     end
          #   end
          #
          # @note The returned Engine handles all the complexity of move validation,
          #   including require/prevent conditions and multiple move variants
          #   (such as promotion choices).
          def to(target)
            transitions = @data.fetch(target)
            Engine.new(*transitions, actor: @actor, origin: @origin, target: target)
          end
        end
      end
    end
  end
end
