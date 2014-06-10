require_relative 'null'
require_relative 'unsigned_integer'

module Sashite
  module GGN
    module PreviousMovesCounter
      PATTERN = /(#{Null::PATTERN}|#{UnsignedInteger::PATTERN})/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io
        raise ArgumentError unless valid? io

        Null.valid?(io) ? Null.load : UnsignedInteger.load(io)
      end
    end
  end
end
