# frozen_string_literal: true

module Sashite
  module Ggn
    # JSON Schema for General Gameplay Notation (GGN) validation.
    #
    # This schema defines the structure and constraints for GGN documents,
    # which describe pseudo-legal moves in abstract strategy board games.
    # GGN is rule-agnostic and focuses on basic movement constraints rather
    # than game-specific legality (e.g., check, ko, repetition).
    #
    # @example Basic GGN document structure
    #   {
    #     "CHESS:K": {
    #       "e1": {
    #         "e2": [
    #           {
    #             "require": { "e2": "empty" },
    #             "perform": { "e1": null, "e2": "CHESS:K" }
    #           }
    #         ]
    #       }
    #     }
    #   }
    #
    # @example Complex move with capture and piece gain
    #   {
    #     "OGI:P": {
    #       "e4": {
    #         "e5": [
    #           {
    #             "require": { "e5": "enemy" },
    #             "perform": { "e4": null, "e5": "OGI:P" },
    #             "gain": "OGI:P"
    #           }
    #         ]
    #       }
    #     }
    #   }
    #
    # @see https://sashite.dev/documents/ggn/1.0.0/ GGN Specification
    # @see https://sashite.dev/schemas/ggn/1.0.0/schema.json JSON Schema URL
    Schema = {
      # JSON Schema meta-information
      "$schema": "https://json-schema.org/draft/2020-12/schema",
      "$id": "https://sashite.dev/schemas/ggn/1.0.0/schema.json",
      "title": "General Gameplay Notation (GGN)",
      "description": "JSON Schema for pseudo-legal moves in abstract board games using the GGN format.",
      "type": "object",

      # Optional schema reference property
      "properties": {
        # Allows documents to self-reference the schema
        "$schema": {
          "type": "string",
          "format": "uri"
        }
      },

      # Pattern-based validation for GAN (General Actor Notation) identifiers
      # Matches format: GAME:piece_char (e.g., "CHESS:K'", "shogi:+p", "XIANGQI:E")
      "patternProperties": {
        # GAN pattern: game identifier (with casing) + colon + piece identifier
        # Supports prefixes (-/+), suffixes ('), and both uppercase/lowercase games
        "^([A-Z]+:[-+]?[A-Z][']?|[a-z]+:[-+]?[a-z][']?)$": {
          "type": "object",
          "minProperties": 1,

          # Source squares: where the piece starts (or "*" for drops)
          "additionalProperties": {
            "type": "object",
            "minProperties": 1,

            # Destination squares: where the piece can move to
            "additionalProperties": {
              "type": "array",
              "minItems": 0,

              # Array of conditional transitions for this source->destination pair
              "items": {
                "type": "object",
                "properties": {
                  # Conditions that MUST be satisfied before the move (logical AND)
                  "require": {
                    "type": "object",
                    "minProperties": 1,
                    "additionalProperties": {
                      "type": "string",
                      # Occupation states: "empty", "enemy", or exact GAN identifier
                      "pattern": "^empty$|^enemy$|([A-Z]+:[-+]?[A-Z][']?|[a-z]+:[-+]?[a-z][']?)$"
                    }
                  },

                  # Conditions that MUST NOT be satisfied before the move (logical OR)
                  "prevent": {
                    "type": "object",
                    "minProperties": 1,
                    "additionalProperties": {
                      "type": "string",
                      # Same occupation states as require
                      "pattern": "^empty$|^enemy$|([A-Z]+:[-+]?[A-Z][']?|[a-z]+:[-+]?[a-z][']?)$"
                    }
                  },

                  # Board state changes after the move (REQUIRED field)
                  "perform": {
                    "type": "object",
                    "minProperties": 1,
                    "additionalProperties": {
                      "anyOf": [
                        {
                          # Square contains a piece (GAN identifier)
                          "type": "string",
                          "pattern": "^([A-Z]+:[-+]?[A-Z][']?|[a-z]+:[-+]?[a-z][']?)$"
                        },
                        {
                          # Square becomes empty (null)
                          "type": "null"
                        }
                      ]
                    }
                  },

                  # Piece added to player's hand (base GAN only, no modifiers)
                  "gain": {
                    "type": ["string", "null"],
                    # Base form GAN pattern (no prefixes/suffixes for hand pieces)
                    "pattern": "^([A-Z]+:[A-Z]|[a-z]+:[a-z])$"
                  },

                  # Piece removed from player's hand (base GAN only, no modifiers)
                  "drop": {
                    "type": ["string", "null"],
                    # Base form GAN pattern (no prefixes/suffixes for hand pieces)
                    "pattern": "^([A-Z]+:[A-Z]|[a-z]+:[a-z])$"
                  }
                },

                # Only "perform" is mandatory; other fields are optional
                "required": ["perform"],
                "additionalProperties": false
              }
            }
          }
        }
      },

      # No additional properties allowed at root level (strict validation)
      "additionalProperties": false
    }.freeze
  end
end
