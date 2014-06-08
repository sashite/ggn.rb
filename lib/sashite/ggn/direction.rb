require_relative 'integer'

module Sashite
  module GGN
    class Direction
      PATTERN = /(#{Integer::PATTERN},)*#{Integer::PATTERN}/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @integers = str.split(',').map { |i| Integer.new(i) }
      end

      def as_json
        @integers.map &:as_json
      end

      def to_s
        @integers.join ','
      end
    end
  end
end
