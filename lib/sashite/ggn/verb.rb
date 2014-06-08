require_relative 'name'
require_relative 'direction'
require_relative 'maximum_magnitude'
require_relative 'required'

module Sashite
  module GGN
    class Verb
      PATTERN = /#{Name::PATTERN}\[#{Direction::PATTERN}\]#{MaximumMagnitude::PATTERN}\/#{Required::PATTERN}/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      attr_reader :name, :direction, :maximum_magnitude, :required

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @name = Name.new str.split('[').fetch 0
        @direction = Direction.new str.split('[').fetch(1).split(']').fetch 0
        @maximum_magnitude = MaximumMagnitude.new str.split(']').fetch(1).split('/').fetch 0
        @required = Required.new str.split('/').fetch 1
      end

      def as_json
        {
          name: @name.as_json,
          vector: {:"...maximum_magnitude" => @maximum_magnitude.as_json, direction: @direction.as_json}
        }
      end

      def to_s
        "#{@name}[#{@direction}]#{@maximum_magnitude}/#{@required}"
      end

      def dimensions
        @direction.as_json.size
      end
    end
  end
end
