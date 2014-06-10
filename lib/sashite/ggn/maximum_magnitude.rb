require_relative 'null'
require_relative 'unsigned_integer_excluding_zero'

module Sashite
  module GGN
    module MaximumMagnitude
      PATTERN = /(#{Null::PATTERN}|#{UnsignedIntegerExcludingZero::PATTERN})/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io
        raise ArgumentError unless valid? io

        Null.valid?(io) ? Null.load : UnsignedIntegerExcludingZero.load(io)
      end
    end
  end
end
