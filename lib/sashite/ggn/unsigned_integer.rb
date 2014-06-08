require_relative 'unsigned_integer_excluding_zero'
require_relative 'zero'

module Sashite
  module GGN
    class UnsignedInteger
      PATTERN = /(#{Zero::PATTERN}|#{UnsignedIntegerExcludingZero::PATTERN})/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @value = (Zero.valid?(str) ? Zero.instance : UnsignedIntegerExcludingZero.new(str))
      end

      def as_json
        @value.as_json
      end

      def to_s
        @value.to_s
      end
    end
  end
end
