require_relative 'integer'

module Sashite
  module GGN
    module Direction
      PATTERN = /(#{Integer::PATTERN},)*#{Integer::PATTERN}/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io
        raise ArgumentError unless valid? io

        io.split(',').map { |s| Integer.load s }
      end
    end
  end
end
