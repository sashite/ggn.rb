require_relative 'ggn/gameplay'

module Sashite
  module GGN
    # Loads a document from the current io stream.
    def self.load io
      Gameplay.load io
    end
  end
end
