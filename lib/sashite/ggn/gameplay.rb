require_relative 'pattern'

module Sashite
  module GGN
    module Gameplay
      PATTERN = /#{Pattern::PATTERN}(\. #{Pattern::PATTERN})*\./

      def self.valid? io
        io.match("^#{PATTERN}$") &&
        io.split('. ').sort.join('. ') == io &&
        io[0..-2].split('. ').uniq.join('. ').concat('.') == io
      end

      def self.load io
        raise ArgumentError unless valid? io
        io[0..-2].split('. ').map { |s| Pattern.load s }
      end
    end
  end
end
