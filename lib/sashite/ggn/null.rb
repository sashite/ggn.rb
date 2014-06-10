module Sashite
  module GGN
    module Null
      PATTERN = /_/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io = nil
        raise ArgumentError if io && !valid?(io)

        nil
      end

      def self.dump
        '_'
      end
    end
  end
end
