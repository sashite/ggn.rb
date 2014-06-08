require_relative 'ally'
require_relative 'actor'
require_relative 'state'

module Sashite
  module GGN
    class Subject
      PATTERN = /#{Ally::PATTERN}<#{Actor::PATTERN}>#{State::PATTERN}/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      attr_reader :ally, :actor, :state

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @ally = Ally.new str.split('<').fetch(0)
        @actor = Actor.new str.split('<').fetch(1).split('>').fetch(0)
        @state = State.new str.split('>').fetch(1)
      end

      def as_json
        {
          :"...ally?" => @ally.as_json,
          actor: @actor.as_json,
          state: @state.as_json
        }
      end

      def to_s
        "#{@ally}<#{@actor}>#{@state}"
      end
    end
  end
end
