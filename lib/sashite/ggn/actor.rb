require_relative 'gameplay_into_base64'
require_relative 'self'

module Sashite
  module GGN
    class Actor
      PATTERN = /(#{Self::PATTERN}|#{GameplayIntoBase64::PATTERN})/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @value = (Self.valid?(str) ? Self.instance : GameplayIntoBase64.new(str))
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
