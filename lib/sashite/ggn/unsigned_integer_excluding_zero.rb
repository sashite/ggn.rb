require_relative 'digit'
require_relative 'digit_excluding_zero'

module Sashite
  module GGN
    class UnsignedIntegerExcludingZero
      PATTERN = /#{DigitExcludingZero::PATTERN}#{Digit::PATTERN}*/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io
        raise ArgumentError unless valid? io

        io.to_i
      end
    end
  end
end
