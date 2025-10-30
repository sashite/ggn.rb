# frozen_string_literal: true

require_relative "ruleset/source"

module Sashite
  module Ggn
    # Immutable container for GGN movement rules
    #
    # @note Instances are created through {Sashite::Ggn.parse}, which handles validation.
    #   The constructor itself does not validate.
    #
    # @see https://sashite.dev/specs/ggn/1.0.0/
    class Ruleset
      # Create a new Ruleset from GGN data structure
      #
      # @note This constructor does not validate the data structure.
      #   Use {Sashite::Ggn.parse} or {Sashite::Ggn.valid?} for validation.
      #
      # @param data [Hash] GGN data structure (pre-validated)
      #
      # @example
      #   # Don't use directly - use Sashite::Ggn.parse instead
      #   ruleset = Sashite::Ggn::Ruleset.new(data)
      def initialize(data)
        @data = data

        freeze
      end

      # Select movement rules for a specific piece type
      #
      # @param piece [String] QPI piece identifier
      # @return [Source] Source selector object
      # @raise [KeyError] If piece not found in ruleset
      #
      # @example
      #   source = ruleset.select("C:K")
      def select(piece)
        raise ::KeyError, "Piece not found: #{piece}" unless piece?(piece)

        Source.new(@data.fetch(piece))
      end

      # Check if ruleset contains movement rules for specified piece
      #
      # @param piece [String] QPI piece identifier
      # @return [Boolean]
      #
      # @example
      #   ruleset.piece?("C:K") # => true
      def piece?(piece)
        @data.key?(piece)
      end

      # Return all piece identifiers in ruleset
      #
      # @return [Array<String>] QPI piece identifiers
      #
      # @example
      #   ruleset.pieces # => ["C:K", "C:Q", "C:P", ...]
      def pieces
        @data.keys
      end
    end
  end
end
