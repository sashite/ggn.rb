require_relative 'negative_integer'
require_relative 'unsigned_integer'

module Sashite
  module GGN
    module Integer
      PATTERN = /(#{NegativeInteger::PATTERN}|#{UnsignedInteger::PATTERN})/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io
        raise ArgumentError unless valid? io

        NegativeInteger.valid?(io) ? NegativeInteger.load(io) : UnsignedInteger.load(io)
      end
    end
  end
end
