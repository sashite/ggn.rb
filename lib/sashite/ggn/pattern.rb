require_relative 'ability'

module Sashite
  module GGN
    module Pattern
      PATTERN = /#{Ability::PATTERN}(; #{Ability::PATTERN})*/

      def self.valid? io
        io.match("^#{PATTERN}$") &&
        io.split('; ').uniq.join('; ') == io
      end

      def self.load io
        raise ArgumentError unless valid? io

        io.split('; ').map { |ability| Ability.load ability }
      end
    end
  end
end
