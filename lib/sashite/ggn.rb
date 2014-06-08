require_relative 'ggn/gameplay'

module Sashite
  module GGN
    def self.load str
      Gameplay.new str
    end
  end
end
