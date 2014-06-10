require_relative 'gameplay_into_base64'
require_relative 'self'

module Sashite
  module GGN
    class Actor
      PATTERN = /(#{Self::PATTERN}|#{GameplayIntoBase64::PATTERN})/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io
        raise ArgumentError unless valid? io

        Self.valid?(io) ? Self.load : GameplayIntoBase64.load(io)
      end
    end
  end
end
