# frozen_string_literal: true

module Sashite
  module Ggn
    # Custom exception class for GGN validation and processing errors.
    #
    # This exception is raised when GGN documents fail validation against
    # the JSON Schema, contain malformed data, or encounter processing errors
    # during parsing and evaluation of pseudo-legal moves.
    #
    # Since GGN focuses exclusively on board-to-board transformations, validation
    # errors typically relate to:
    # - Invalid board position representations
    # - Malformed GAN identifiers or square labels
    # - Logical contradictions in require/prevent conditions
    # - Missing or invalid perform actions
    #
    # Common scenarios that raise ValidationError:
    # - Invalid JSON syntax in GGN files
    # - Schema validation failures (missing required fields, invalid patterns)
    # - File system errors (file not found, permission denied)
    # - Malformed GAN identifiers or square labels
    # - Logical contradictions in require/prevent conditions
    # - Invalid board transformation specifications
    #
    # @example Handling validation errors during file loading
    #   begin
    #     piece_data = Sashite::Ggn.load_file('invalid_moves.json')
    #   rescue Sashite::Ggn::ValidationError => e
    #     puts "GGN validation failed: #{e.message}"
    #     # Handle the error appropriately
    #   end
    #
    # @example Handling validation errors during move evaluation
    #   begin
    #     transitions = engine.where(board_state, 'CHESS')
    #   rescue Sashite::Ggn::ValidationError => e
    #     puts "Move evaluation failed: #{e.message}"
    #     # Handle invalid board state or parameters
    #   end
    #
    # @example Handling schema validation errors
    #   begin
    #     Sashite::Ggn.validate!(ggn_data)
    #   rescue Sashite::Ggn::ValidationError => e
    #     puts "Schema validation failed: #{e.message}"
    #     # The data doesn't conform to GGN specification
    #   end
    #
    # @see Sashite::Ggn.load_file Main method that can raise this exception
    # @see Sashite::Ggn.validate! Schema validation method
    # @see Sashite::Ggn::Schema JSON Schema used for validation
    class ValidationError < ::StandardError
    end
  end
end
