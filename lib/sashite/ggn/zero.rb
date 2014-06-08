require 'singleton'

module Sashite
  module GGN
    class Zero
      include Singleton

      PATTERN = /0/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      def as_json
        0
      end

      def to_s
        '0'
      end
    end
  end
end
