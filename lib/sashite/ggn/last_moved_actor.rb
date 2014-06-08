require_relative 'boolean'
require_relative 'null'

module Sashite
  module GGN
    class LastMovedActor
      PATTERN = /(#{Boolean::PATTERN}|#{Null::PATTERN})/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @value = (Null.valid?(str) ? Null.instance : Boolean.new(str))
      end

      def as_json
        @value.as_json
      end

      def to_s
        @value.to_s
      end
    end
  end
end
