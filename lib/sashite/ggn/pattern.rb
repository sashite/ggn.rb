require_relative 'ability'

module Sashite
  module GGN
    class Pattern
      PATTERN = /#{Ability::PATTERN}(; #{Ability::PATTERN})*/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      attr_reader :abilities

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @abilities = str.split('; ').map { |ability| Ability.new ability }
      end

      def as_json
        @abilities.map &:as_json
      end

      def to_s
        @abilities.map(&:to_s).join '; '
      end
    end
  end
end
