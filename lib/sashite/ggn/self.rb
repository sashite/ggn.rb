module Sashite
  module GGN
    module Self
      PATTERN = /self/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io = nil
        raise ArgumentError if io && !valid?(io)

        :self
      end

      def self.dump
        'self'
      end
    end
  end
end
