require_relative 'attacked'
require_relative 'occupied'
require_relative 'area'

module Sashite
  module GGN
    module Square
      PATTERN = /#{Attacked::PATTERN}@#{Occupied::PATTERN}\+#{Area::PATTERN}/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io
        raise ArgumentError unless valid? io

        attacked = Attacked.load io.split('@').fetch(0)
        occupied = Occupied.load io.split('@').fetch(1).split('+').fetch(0)
        area = Area.load io.split('+').fetch(1)

        {
          :"...attacked?" => attacked,
          :"...occupied!" => occupied,
          :"area" => area
        }
      end
    end
  end
end
