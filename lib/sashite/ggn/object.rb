require_relative 'square'

module Sashite
  module GGN
    class Object
      attr_accessor :src_square, :dst_square, :promotable_into_actors
    end
  end
end
