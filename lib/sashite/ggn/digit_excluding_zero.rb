module Sashite
  module GGN
    module DigitExcludingZero
      PATTERN = /[1-9]/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io
        raise ArgumentError unless valid? io

        io.to_i
      end
    end
  end
end
