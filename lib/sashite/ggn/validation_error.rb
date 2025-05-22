# frozen_string_literal: true

module Sashite
  module Ggn
    # Custom exception class for GGN validation and processing errors.
    #
    # This exception is raised when GGN documents fail validation against
    # the JSON Schema, contain malformed data, or encounter processing errors
    # during parsing and evaluation of pseudo-legal moves.
    #
    # Common scenarios that raise ValidationError:
    # - Invalid JSON syntax in GGN files
    # - Schema validation failures (missing required fields, invalid patterns)
    # - File system errors (file not found, permission denied)
    # - Malformed GAN identifiers or square labels
    # - Logical contradictions in require/prevent conditions
    #
    # @example Handling validation errors during file loading
    #   begin
    #     piece = Sashite::Ggn.load_file('invalid_moves.json')
    #   rescue Sashite::Ggn::ValidationError => e
    #     puts "GGN validation failed: #{e.message}"
    #     # Handle the error appropriately
    #   end
    #
    # @see Sashite::Ggn.load_file Main method that can raise this exception
    # @see Sashite::Ggn::Schema JSON Schema used for validation
    class ValidationError < ::StandardError
    end
  end
end
