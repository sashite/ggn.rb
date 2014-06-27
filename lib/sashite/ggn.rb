require_relative 'ggn/gameplay'

module Sashite
  module GGN
    # Loads a document from the current io stream.
    def self.new
      Gameplay.new
    end
  end
end
