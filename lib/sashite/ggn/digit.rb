require_relative 'digit_excluding_zero'
require_relative 'zero'

module Sashite
  module GGN
    module Digit
      PATTERN = /(#{Zero::PATTERN}|#{DigitExcludingZero::PATTERN})/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io
        raise ArgumentError unless valid? io

        Zero.valid?(io) ? Zero.load : DigitExcludingZero.load(io)
      end
    end
  end
end
