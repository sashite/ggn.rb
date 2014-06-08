require_relative 'attacked'
require_relative 'occupied'
require_relative 'area'

module Sashite
  module GGN
    class Square
      PATTERN = /#{Attacked::PATTERN}@#{Occupied::PATTERN}\+#{Area::PATTERN}/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      attr_reader :attacked, :occupied, :area

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @attacked = Attacked.new str.split('@').fetch(0)
        @occupied = Occupied.new str.split('@').fetch(1).split('+').fetch(0)
        @area = Area.new str.split('+').fetch(1)
      end

      def as_json
        {
          :"...attacked?" => @attacked.as_json,
          :"...occupied!" => @occupied.as_json,
          :"area" => @area.as_json
        }
      end

      def to_s
        "#{@attacked}@#{@occupied}+#{@area}"
      end
    end
  end
end
