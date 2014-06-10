require_relative 'unsigned_integer_excluding_zero'

module Sashite
  module GGN
    module NegativeInteger
      PATTERN = /-#{UnsignedIntegerExcludingZero::PATTERN}/

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
