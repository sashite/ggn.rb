# frozen_string_literal: true

require "sashite/cell"
require "sashite/hand"
require "sashite/lcn"
require "sashite/qpi"
require "sashite/stn"

require_relative "ruleset/source"

module Sashite
  module Ggn
    # Immutable container for GGN movement rules
    #
    # @see https://sashite.dev/specs/ggn/1.0.0/
    class Ruleset
      # @return [Hash] The underlying GGN data structure
      attr_reader :data

      # Create a new Ruleset from GGN data structure
      #
      # @param data [Hash] GGN data structure
      # @raise [ArgumentError] If data structure is invalid
      # @example With invalid structure
      #   begin
      #     Sashite::Ggn::Ruleset.new({ "invalid" => "data" })
      #   rescue ArgumentError => e
      #     puts e.message # => "Invalid QPI format: invalid"
      #   end
      def initialize(data)
        validate_structure!(data)
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

        Source.new(piece, data.fetch(piece))
      end

      # Generate all pseudo-legal moves for the given position
      #
      # @note This method evaluates all possible moves in the ruleset.
      #   For large rulesets, consider filtering by active pieces first.
      #
      # @param feen [String] Position in FEEN format
      # @return [Array<Array(String, String, String, Array<Sashite::Stn::Transition>)>]
      #   Array of tuples containing:
      #   - piece (String): QPI identifier
      #   - source (String): CELL coordinate or HAND "*"
      #   - destination (String): CELL coordinate or HAND "*"
      #   - transitions (Array<Sashite::Stn::Transition>): Valid state transitions
      #
      # @example
      #   moves = ruleset.pseudo_legal_transitions(feen)
      def pseudo_legal_transitions(feen)
        pieces.flat_map do |piece|
          source = select(piece)

          source.sources.flat_map do |src|
            destination = source.from(src)

            destination.destinations.flat_map do |dest|
              engine = destination.to(dest)
              transitions = engine.where(feen)

              transitions.empty? ? [] : [[piece, src, dest, transitions]]
            end
          end
        end
      end

      # Check if ruleset contains movement rules for specified piece
      #
      # @param piece [String] QPI piece identifier
      # @return [Boolean]
      #
      # @example
      #   ruleset.piece?("C:K") # => true
      def piece?(piece)
        data.key?(piece)
      end

      # Return all piece identifiers in ruleset
      #
      # @return [Array<String>] QPI piece identifiers
      #
      # @example
      #   ruleset.pieces # => ["C:K", "C:Q", "C:P", ...]
      def pieces
        data.keys
      end

      # Convert ruleset to hash representation
      #
      # @return [Hash] GGN data structure
      #
      # @example
      #   ruleset.to_h # => { "C:K" => { "e1" => { "e2" => [...] } } }
      def to_h
        data
      end

      private

      # Validate GGN data structure
      #
      # @param data [Hash] Data to validate
      # @raise [ArgumentError] If structure is invalid
      # @return [void]
      def validate_structure!(data)
        raise ::ArgumentError, "GGN data must be a Hash" unless data.is_a?(::Hash)

        data.each do |piece, sources|
          validate_piece!(piece)
          validate_sources!(sources, piece)
        end
      end

      # Validate QPI piece identifier using sashite-qpi
      #
      # @param piece [String] Piece identifier to validate
      # @raise [ArgumentError] If piece identifier is invalid
      # @return [void]
      def validate_piece!(piece)
        raise ::ArgumentError, "Invalid piece identifier: #{piece}" unless piece.is_a?(::String)
        raise ::ArgumentError, "Invalid QPI format: #{piece}" unless Qpi.valid?(piece)
      end

      # Validate sources hash structure
      #
      # @param sources [Hash] Sources hash to validate
      # @param piece [String] Piece identifier (for error messages)
      # @raise [ArgumentError] If sources structure is invalid
      # @return [void]
      def validate_sources!(sources, piece)
        raise ::ArgumentError, "Sources for #{piece} must be a Hash" unless sources.is_a?(::Hash)

        sources.each do |source, destinations|
          validate_location!(source, piece)
          validate_destinations!(destinations, piece, source)
        end
      end

      # Validate destinations hash structure
      #
      # @param destinations [Hash] Destinations hash to validate
      # @param piece [String] Piece identifier (for error messages)
      # @param source [String] Source location (for error messages)
      # @raise [ArgumentError] If destinations structure is invalid
      # @return [void]
      def validate_destinations!(destinations, piece, source)
        raise ::ArgumentError, "Destinations for #{piece} from #{source} must be a Hash" unless destinations.is_a?(::Hash)

        destinations.each do |destination, possibilities|
          validate_location!(destination, piece)
          validate_possibilities!(possibilities, piece, source, destination)
        end
      end

      # Validate possibilities array structure
      #
      # @param possibilities [Array] Possibilities array to validate
      # @param piece [String] Piece identifier (for error messages)
      # @param source [String] Source location (for error messages)
      # @param destination [String] Destination location (for error messages)
      # @raise [ArgumentError] If possibilities structure is invalid
      # @return [void]
      def validate_possibilities!(possibilities, piece, source, destination)
        raise ::ArgumentError, "Possibilities for #{piece} #{source}→#{destination} must be an Array" unless possibilities.is_a?(::Array)

        possibilities.each do |possibility|
          validate_possibility!(possibility, piece, source, destination)
        end
      end

      # Validate individual possibility structure using LCN and STN gems
      #
      # @param possibility [Hash] Possibility to validate
      # @param piece [String] Piece identifier (for error messages)
      # @param source [String] Source location (for error messages)
      # @param destination [String] Destination location (for error messages)
      # @raise [ArgumentError] If possibility structure is invalid
      # @return [void]
      def validate_possibility!(possibility, piece, source, destination)
        raise ::ArgumentError, "Possibility for #{piece} #{source}→#{destination} must be a Hash" unless possibility.is_a?(::Hash)
        raise ::ArgumentError, "Possibility must have 'must' field" unless possibility.key?("must")
        raise ::ArgumentError, "Possibility must have 'deny' field" unless possibility.key?("deny")
        raise ::ArgumentError, "Possibility must have 'diff' field" unless possibility.key?("diff")

        validate_lcn_conditions!(possibility["must"], "must", piece, source, destination)
        validate_lcn_conditions!(possibility["deny"], "deny", piece, source, destination)
        validate_stn_transition!(possibility["diff"], piece, source, destination)
      end

      # Validate LCN conditions using sashite-lcn
      #
      # @param conditions [Hash] Conditions to validate
      # @param field_name [String] Field name for error messages
      # @param piece [String] Piece identifier (for error messages)
      # @param source [String] Source location (for error messages)
      # @param destination [String] Destination location (for error messages)
      # @raise [ArgumentError] If conditions are invalid
      # @return [void]
      def validate_lcn_conditions!(conditions, field_name, piece, source, destination)
        Lcn.parse(conditions)
      rescue ArgumentError => e
        raise ::ArgumentError, "Invalid LCN format in '#{field_name}' for #{piece} #{source}→#{destination}: #{e.message}"
      end

      # Validate STN transition using sashite-stn
      #
      # @param transition [Hash] Transition to validate
      # @param piece [String] Piece identifier (for error messages)
      # @param source [String] Source location (for error messages)
      # @param destination [String] Destination location (for error messages)
      # @raise [ArgumentError] If transition is invalid
      # @return [void]
      def validate_stn_transition!(transition, piece, source, destination)
        Stn.parse(transition)
      rescue StandardError => e
        raise ::ArgumentError, "Invalid STN format in 'diff' for #{piece} #{source}→#{destination}: #{e.message}"
      end

      # Validate location format using CELL and HAND gems
      #
      # @param location [String] Location to validate
      # @param piece [String] Piece identifier (for error messages)
      # @raise [ArgumentError] If location format is invalid
      # @return [void]
      def validate_location!(location, piece)
        raise ::ArgumentError, "Location for #{piece} must be a String" unless location.is_a?(::String)

        valid = Cell.valid?(location) || Hand.reserve?(location)
        raise ::ArgumentError, "Invalid location format: #{location}" unless valid
      end
    end
  end
end
