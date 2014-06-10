require_relative 'actor'
require_relative 'gameplay_into_base64'

module Sashite
  module GGN
    module PromotableIntoActors
      PATTERN = /(#{GameplayIntoBase64::PATTERN},)*#{Actor::PATTERN}/

      def self.valid? io
        io.match("^#{PATTERN}$") &&
        io.split(',').uniq.join(',') == io
      end

      def self.load io
        raise ArgumentError unless valid? io

        io.split(',').map do |value|
          Actor.valid?(value) ? Actor.load(value) : GameplayIntoBase64.load(value)
        end
      end
    end
  end
end
