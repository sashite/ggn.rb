require_relative 'boolean'
require_relative 'null'

module Sashite
  module GGN
    module Ally
      PATTERN = /(#{Boolean::PATTERN}|#{Null::PATTERN})/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io
        raise ArgumentError unless valid? io

        Null.valid?(io) ? Null.load : Boolean.load(io)
      end
    end
  end
end
