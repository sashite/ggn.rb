require_relative 'negative_integer'
require_relative 'unsigned_integer'

module Sashite
  module GGN
    class Integer
      PATTERN = /(#{NegativeInteger::PATTERN}|#{UnsignedInteger::PATTERN})/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @value = (NegativeInteger.valid?(str) ? NegativeInteger.new(str) : UnsignedInteger.new(str))
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
