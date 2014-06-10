module Sashite
  module GGN
    module Name
      PATTERN = /(capture|remove|shift)/

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
