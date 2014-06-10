require 'base64'
require_relative 'gameplay'

module Sashite
  module GGN
    module GameplayIntoBase64
      PATTERN = /(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=)?/

      def self.valid? io
        io.match("^#{PATTERN}$") &&
        Gameplay.valid?(Base64.strict_decode64(io))
      end

      def self.load io
        raise ArgumentError unless valid? io

        Gameplay.load Base64.strict_decode64(io)
      end
    end
  end
end
