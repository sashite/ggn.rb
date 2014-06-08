require 'sashite-cgh'
require_relative 'pattern'

module Sashite
  module GGN
    class Gameplay
      PATTERN = /#{Pattern::PATTERN}(\. #{Pattern::PATTERN})*\./

      def self.valid? str
        !!str.match("^#{PATTERN}$") && str.split('. ').sort.join('. ') == str
      end

      attr_reader :patterns

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @patterns = str[0..-2].split('. ').map { |pattern| Pattern.new pattern }
      end

      def as_json
        @patterns.map &:as_json
      end

      def to_s
        @patterns.map(&:to_s).join('. ') + '.'
      end

      def to_cgh
        Sashite::CGH.parse to_s
      end

      def dimensions
        first_pattern = @patterns.fetch 0
        first_ability = first_pattern.abilities.fetch 0
        first_ability.verb.dimensions
      end
    end
  end
end
