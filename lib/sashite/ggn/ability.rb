require_relative 'subject'
require_relative 'verb'
require_relative 'object'

module Sashite
  module GGN
    class Ability
      attr_accessor :subject, :verb, :object
    end
  end
end
