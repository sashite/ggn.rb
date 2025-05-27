# frozen_string_literal: true

module Sashite
  module Ggn
    # JSON Schema for General Gameplay Notation (GGN) validation.
    #
    # This schema defines the structure and constraints for GGN documents,
    # which describe pseudo-legal moves in abstract strategy board games.
    # GGN is rule-agnostic and focuses exclusively on board-to-board transformations:
    # pieces moving, capturing, or transforming on the game board.
    #
    # The schema has been updated to reflect GGN's focus on board transformations only.
    # Hand management, piece drops, and captures-to-hand are outside the scope of GGN.
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
    # @example Complex move with multiple conditions
    #   {
    #     "CHESS:P": {
    #       "d5": {
    #         "e6": [
    #           {
    #             "require": { "e5": "chess:p", "e6": "empty" },
    #             "perform": { "d5": null, "e5": null, "e6": "CHESS:P" }
    #           }
    #         ]
    #       }
    #     }
    #   }
    #
    # @example Multi-square move (castling)
    #   {
    #     "CHESS:K": {
    #       "e1": {
    #         "g1": [
    #           {
    #             "require": { "f1": "empty", "g1": "empty", "h1": "CHESS:R" },
    #             "perform": { "e1": null, "f1": "CHESS:R", "g1": "CHESS:K", "h1": null }
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
      "description": "JSON Schema for pseudo-legal moves in abstract board games using the GGN format. GGN focuses exclusively on board-to-board transformations.",
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

          # Source squares: where the piece starts (regular board squares only)
          "patternProperties": {
            ".+": {
              "type": "object",
              "minProperties": 1,

              # Destination squares: where the piece can move to (regular board squares only)
              "patternProperties": {
                ".+": {
                  "type": "array",
                  "minItems": 1,

                  # Array of conditional transitions for this source->destination pair
                  "items": {
                    "type": "object",
                    "properties": {
                      # Conditions that MUST be satisfied before the move (logical AND)
                      "require": {
                        "type": "object",
                        "minProperties": 1,
                        "patternProperties": {
                          ".+": {
                            "type": "string",
                            # Occupation states: "empty", "enemy", or exact GAN identifier
                            "pattern": "^(empty|enemy|[A-Z]+:[-+]?[A-Z][']?|[a-z]+:[-+]?[a-z][']?)$"
                          }
                        },
                        "additionalProperties": false
                      },

                      # Conditions that MUST NOT be satisfied before the move (logical OR)
                      "prevent": {
                        "type": "object",
                        "minProperties": 1,
                        "patternProperties": {
                          ".+": {
                            "type": "string",
                            # Same occupation states as require
                            "pattern": "^(empty|enemy|[A-Z]+:[-+]?[A-Z][']?|[a-z]+:[-+]?[a-z][']?)$"
                          }
                        },
                        "additionalProperties": false
                      },

                      # Board state changes after the move (REQUIRED field)
                      # This is the core of GGN: describing board transformations
                      "perform": {
                        "type": "object",
                        "minProperties": 1,
                        "patternProperties": {
                          ".+": {
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
                        "additionalProperties": false
                      }
                    },

                    # Only "perform" is mandatory; "require" and "prevent" are optional
                    # NOTE: "gain" and "drop" fields are no longer supported in GGN
                    "required": ["perform"],
                    "additionalProperties": false
                  }
                }
              },
              "additionalProperties": false
            }
          },
          "additionalProperties": false
        }
      },

      # No additional properties allowed at root level (strict validation)
      "additionalProperties": false
    }.freeze
  end
end
