require_relative 'last_moved_actor'
require_relative 'previous_moves_counter'

module Sashite
  module GGN
    class State
      PATTERN = /#{LastMovedActor::PATTERN}&#{PreviousMovesCounter::PATTERN}/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      attr_reader :previous_moves_counter, :last_moved_actor

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @last_moved_actor = LastMovedActor.new str.split('&').fetch(0)
        @previous_moves_counter = PreviousMovesCounter.new str.split('&').fetch(1)
      end

      def as_json
        {
          :"...last_moved_actor?" => @last_moved_actor.as_json,
          :"...previous_moves_counter" => @previous_moves_counter.as_json
        }
      end

      def to_s
        "#{@last_moved_actor}&#{@previous_moves_counter}"
      end
    end
  end
end
