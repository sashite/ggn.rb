require_relative 'unsigned_integer_excluding_zero'

module Sashite
  module GGN
    class NegativeInteger
      PATTERN = /-#{UnsignedIntegerExcludingZero::PATTERN}/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @value = str.to_i
      end

      def as_json
        @value
      end

      def to_s
        @value.to_s
      end
    end
  end
end
