require_relative 'direction'
require_relative 'maximum_magnitude'
require_relative 'name'
require_relative 'required'

module Sashite
  module GGN
    module Verb
      PATTERN = /#{Name::PATTERN}\[#{Direction::PATTERN}\]#{MaximumMagnitude::PATTERN}\/#{Required::PATTERN}/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io
        raise ArgumentError unless valid? io

        name = Name.load io.split('[').fetch 0
        direction = Direction.load io.split('[').fetch(1).split(']').fetch 0
        maximum_magnitude = MaximumMagnitude.load io.split(']').fetch(1).split('/').fetch 0
        required = Required.load io.split('/').fetch 1

        {
          name: name,
          vector: {
            :"...maximum_magnitude" => maximum_magnitude,
            direction: direction
          }
        }
      end
    end
  end
end
