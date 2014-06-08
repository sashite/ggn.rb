require_relative 'boolean'

module Sashite
  module GGN
    class Required
      PATTERN = /#{Boolean::PATTERN}/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @value = Boolean.new(str)
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
