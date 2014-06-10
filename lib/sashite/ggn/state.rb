require_relative 'last_moved_actor'
require_relative 'previous_moves_counter'

module Sashite
  module GGN
    module State
      PATTERN = /#{LastMovedActor::PATTERN}&#{PreviousMovesCounter::PATTERN}/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io
        raise ArgumentError unless valid? io

        last_moved_actor = LastMovedActor.load io.split('&').fetch(0)
        previous_moves_counter = PreviousMovesCounter.load io.split('&').fetch(1)

        {
          :"...last_moved_actor?" => last_moved_actor,
          :"...previous_moves_counter" => previous_moves_counter
        }
      end
    end
  end
end
