module Sashite
  module GGN
    module Zero
      PATTERN = /0/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io = nil
        raise ArgumentError if io && !valid?(io)

        0
      end

      def self.dump
        '0'
      end
    end
  end
end
