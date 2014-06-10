module Sashite
  module GGN
    module Area
      PATTERN = /(all|furthest_rank|palace|furthest_one-third|nearest_two-thirds)/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io
        raise ArgumentError unless valid? io

        io.to_sym
      end
    end
  end
end
