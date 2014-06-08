require_relative 'actor'
require_relative 'gameplay_into_base64'

module Sashite
  module GGN
    class PromotableIntoActors
      PATTERN = /(#{GameplayIntoBase64::PATTERN},)*#{Actor::PATTERN}/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      attr_reader :values

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @values = str.split(',').map do |value|
          Actor.valid?(value) ? Actor.new(value) : GameplayIntoBase64.new(value)
        end
      end

      def as_json
        @values.map &:as_json
      end

      def to_s
        @values.map(&:to_s).join ','
      end
    end
  end
end
