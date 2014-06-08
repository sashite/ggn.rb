require_relative 'square'
require_relative 'promotable_into_actors'

module Sashite
  module GGN
    class Object
      PATTERN = /#{Square::PATTERN}~#{Square::PATTERN}%#{PromotableIntoActors::PATTERN}/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      attr_reader :src_square, :dst_square, :promotable_into_actors

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @src_square = Square.new str.split('~').fetch 0
        @dst_square = Square.new str.split('~').fetch(1).split('%').fetch 0
        @promotable_into_actors = PromotableIntoActors.new str.split('%').fetch 1
      end

      def as_json
        {
          src_square: @src_square.as_json,
          dst_square: @dst_square.as_json,
          promotable_into_actors: @promotable_into_actors.as_json
        }
      end

      def to_s
        "#{@src_square}~#{@dst_square}%#{@promotable_into_actors}"
      end
    end
  end
end
