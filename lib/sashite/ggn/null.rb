require 'singleton'

module Sashite
  module GGN
    class Null
      include Singleton

      PATTERN = /_/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      def as_json
        nil
      end

      def to_s
        '_'
      end
    end
  end
end
