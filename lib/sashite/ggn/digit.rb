require_relative 'digit_excluding_zero'
require_relative 'zero'

module Sashite
  module GGN
    class Digit
      PATTERN = /(#{Zero::PATTERN}|#{DigitExcludingZero::PATTERN})/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @value = (Zero.valid?(str) ? Zero.instance : DigitExcludingZero.new(str))
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
