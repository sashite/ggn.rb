module Sashite
  module GGN
    module Boolean
      PATTERN = /[ft]/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io
        raise ArgumentError unless valid? io

        io.to_sym == :t
      end
    end
  end
end
