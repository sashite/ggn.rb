# frozen_string_literal: true

require_relative "ggn/ruleset"

module Sashite
  # General Gameplay Notation (GGN) implementation
  #
  # GGN is a rule-agnostic format for describing pseudo-legal moves
  # in abstract strategy board games.
  #
  # @see https://sashite.dev/specs/ggn/1.0.0/
  module Ggn
    # Parse GGN data structure into an immutable Ruleset
    #
    # @param data [Hash] GGN data structure conforming to specification
    # @return [Ruleset] Immutable ruleset object
    # @raise [ArgumentError, TypeError] If data structure is invalid
    #
    # @example Parse GGN data
    #   ruleset = Sashite::Ggn.parse({
    #     "C:P" => {
    #       "e2" => {
    #         "e4" => [
    #           {
    #             "must" => { "e3" => "empty", "e4" => "empty" },
    #             "deny" => {},
    #             "diff" => {
    #               "board" => { "e2" => nil, "e4" => "C:P" },
    #               "toggle" => true
    #             }
    #           }
    #         ]
    #       }
    #     }
    #   })
    def self.parse(data)
      Ruleset.new(data)
    end

    # Validate GGN data structure against specification
    #
    # @param data [Hash] Data structure to validate
    # @return [Boolean] True if valid, false otherwise
    #
    # @note Rescues both ArgumentError (invalid structure) and TypeError (wrong type)
    #
    # @example Validate GGN data
    #   Sashite::Ggn.valid?(ggn_data) # => true
    #   Sashite::Ggn.valid?("invalid") # => false (TypeError)
    #   Sashite::Ggn.valid?(nil) # => false (TypeError)
    def self.valid?(data)
      parse(data)
      true
    rescue ::ArgumentError, ::TypeError
      false
    end
  end
end
