require 'base64'
require_relative 'gameplay'

module Sashite
  module GGN
    class GameplayIntoBase64
      PATTERN = /(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=)?/

      def self.valid? str
        !!str.match("^#{PATTERN}$") && Gameplay.valid?(Base64.strict_decode64(str))
      end

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @value = Gameplay.new Base64.strict_decode64(str)
      end

      def as_json
        @value.as_json
      end

      def to_s
        Base64.strict_encode64 @value.to_s
      end
    end
  end
end
