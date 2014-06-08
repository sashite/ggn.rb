module Sashite
  module GGN
    class Area
      PATTERN = /(all|furthest_rank|palace|furthest_one-third|nearest_two-thirds)/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @value = str.to_sym
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
