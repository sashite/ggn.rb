require_relative 'square'
require_relative 'promotable_into_actors'

module Sashite
  module GGN
    module Object
      PATTERN = /#{Square::PATTERN}~#{Square::PATTERN}%#{PromotableIntoActors::PATTERN}/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io
        raise ArgumentError unless valid? io

        src_square = Square.load io.split('~').fetch 0
        dst_square = Square.load io.split('~').fetch(1).split('%').fetch 0
        promotable_into_actors = PromotableIntoActors.load io.split('%').fetch 1

        {
          src_square: src_square,
          dst_square: dst_square,
          promotable_into_actors: promotable_into_actors
        }
      end
    end
  end
end
