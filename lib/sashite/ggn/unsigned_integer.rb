require_relative 'unsigned_integer_excluding_zero'
require_relative 'zero'

module Sashite
  module GGN
    module UnsignedInteger
      PATTERN = /(#{Zero::PATTERN}|#{UnsignedIntegerExcludingZero::PATTERN})/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io
        raise ArgumentError unless valid? io

        Zero.valid?(io) ? Zero.load : UnsignedIntegerExcludingZero.load(io)
      end
    end
  end
end
