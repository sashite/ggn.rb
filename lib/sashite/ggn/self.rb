require 'singleton'

module Sashite
  module GGN
    class Self
      include Singleton

      PATTERN = /self/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      def as_json
        :self
      end

      def to_s
        'self'
      end
    end
  end
end
