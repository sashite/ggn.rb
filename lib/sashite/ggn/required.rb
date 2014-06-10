require_relative 'boolean'

module Sashite
  module GGN
    module Required
      PATTERN = /#{Boolean::PATTERN}/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io
        raise ArgumentError unless valid? io

        Boolean.load io
      end
    end
  end
end
