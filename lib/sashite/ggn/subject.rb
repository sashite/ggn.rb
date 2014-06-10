require_relative 'ally'
require_relative 'actor'
require_relative 'state'

module Sashite
  module GGN
    module Subject
      PATTERN = /#{Ally::PATTERN}<#{Actor::PATTERN}>#{State::PATTERN}/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io
        raise ArgumentError unless valid? io

        ally = Ally.load io.split('<').fetch(0)
        actor = Actor.load io.split('<').fetch(1).split('>').fetch(0)
        state = State.load io.split('>').fetch(1)

        {
          :"...ally?" => ally,
          actor: actor,
          state: state
        }
      end
    end
  end
end
