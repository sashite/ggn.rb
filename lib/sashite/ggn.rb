# frozen_string_literal: true

require "sashite/cell"
require "sashite/hand"
require "sashite/lcn"
require "sashite/qpi"
require "sashite/stn"

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
    # @raise [ArgumentError] If data structure is invalid
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
      validate!(data)
      Ruleset.new(data)
    end

    # Validate GGN data structure against specification
    #
    # @param data [Hash] Data structure to validate
    # @return [Boolean] True if valid, false otherwise
    #
    # @example Validate GGN data
    #   Sashite::Ggn.valid?(ggn_data) # => true
    #   Sashite::Ggn.valid?("invalid") # => false
    #   Sashite::Ggn.valid?(nil) # => false
    def self.valid?(data)
      validate!(data)
      true
    rescue ::ArgumentError
      false
    end

    # Validate GGN data structure
    #
    # @param data [Object] Data to validate
    # @raise [ArgumentError] If structure is invalid
    # @return [void]
    # @api private
    def self.validate!(data)
      raise ::ArgumentError, "GGN data must be a Hash" unless data.is_a?(::Hash)

      data.each do |piece, sources|
        validate_piece!(piece)
        validate_sources!(sources, piece)
      end
    end
    private_class_method :validate!

    # Validate QPI piece identifier
    #
    # @param piece [String] Piece identifier to validate
    # @raise [ArgumentError] If piece identifier is invalid
    # @return [void]
    # @api private
    def self.validate_piece!(piece)
      raise ::ArgumentError, "Invalid piece identifier: #{piece}" unless piece.is_a?(::String)
      raise ::ArgumentError, "Invalid QPI format: #{piece}" unless Qpi.valid?(piece)
    end
    private_class_method :validate_piece!

    # Validate sources hash structure
    #
    # @param sources [Hash] Sources hash to validate
    # @param piece [String] Piece identifier (for error messages)
    # @raise [ArgumentError] If sources structure is invalid
    # @return [void]
    # @api private
    def self.validate_sources!(sources, piece)
      raise ::ArgumentError, "Sources for #{piece} must be a Hash" unless sources.is_a?(::Hash)

      sources.each do |source, destinations|
        validate_location!(source, piece)
        validate_destinations!(destinations, piece, source)
      end
    end
    private_class_method :validate_sources!

    # Validate destinations hash structure
    #
    # @param destinations [Hash] Destinations hash to validate
    # @param piece [String] Piece identifier (for error messages)
    # @param source [String] Source location (for error messages)
    # @raise [ArgumentError] If destinations structure is invalid
    # @return [void]
    # @api private
    def self.validate_destinations!(destinations, piece, source)
      raise ::ArgumentError, "Destinations for #{piece} from #{source} must be a Hash" unless destinations.is_a?(::Hash)

      destinations.each do |destination, possibilities|
        validate_location!(destination, piece)
        validate_possibilities!(possibilities, piece, source, destination)
      end
    end
    private_class_method :validate_destinations!

    # Validate possibilities array structure
    #
    # @param possibilities [Array] Possibilities array to validate
    # @param piece [String] Piece identifier (for error messages)
    # @param source [String] Source location (for error messages)
    # @param destination [String] Destination location (for error messages)
    # @raise [ArgumentError] If possibilities structure is invalid
    # @return [void]
    # @api private
    def self.validate_possibilities!(possibilities, piece, source, destination)
      unless possibilities.is_a?(::Array)
        raise ::ArgumentError, "Possibilities for #{piece} #{source}→#{destination} must be an Array"
      end

      possibilities.each do |possibility|
        validate_possibility!(possibility, piece, source, destination)
      end
    end
    private_class_method :validate_possibilities!

    # Validate individual possibility structure
    #
    # @param possibility [Hash] Possibility to validate
    # @param piece [String] Piece identifier (for error messages)
    # @param source [String] Source location (for error messages)
    # @param destination [String] Destination location (for error messages)
    # @raise [ArgumentError] If possibility structure is invalid
    # @return [void]
    # @api private
    def self.validate_possibility!(possibility, piece, source, destination)
      unless possibility.is_a?(::Hash)
        raise ::ArgumentError, "Possibility for #{piece} #{source}→#{destination} must be a Hash"
      end
      raise ::ArgumentError, "Possibility must have 'must' field" unless possibility.key?("must")
      raise ::ArgumentError, "Possibility must have 'deny' field" unless possibility.key?("deny")
      raise ::ArgumentError, "Possibility must have 'diff' field" unless possibility.key?("diff")

      validate_lcn_conditions!(possibility["must"], "must", piece, source, destination)
      validate_lcn_conditions!(possibility["deny"], "deny", piece, source, destination)
      validate_stn_transition!(possibility["diff"], piece, source, destination)
    end
    private_class_method :validate_possibility!

    # Validate LCN conditions
    #
    # @param conditions [Hash] Conditions to validate
    # @param field_name [String] Field name for error messages
    # @param piece [String] Piece identifier (for error messages)
    # @param source [String] Source location (for error messages)
    # @param destination [String] Destination location (for error messages)
    # @raise [ArgumentError] If conditions are invalid
    # @return [void]
    # @api private
    def self.validate_lcn_conditions!(conditions, field_name, piece, source, destination)
      Lcn.parse(conditions)
    rescue ::ArgumentError => e
      raise ::ArgumentError, "Invalid LCN format in '#{field_name}' for #{piece} #{source}→#{destination}: #{e.message}"
    end
    private_class_method :validate_lcn_conditions!

    # Validate STN transition
    #
    # @param transition [Hash] Transition to validate
    # @param piece [String] Piece identifier (for error messages)
    # @param source [String] Source location (for error messages)
    # @param destination [String] Destination location (for error messages)
    # @raise [ArgumentError] If transition is invalid
    # @return [void]
    # @api private
    def self.validate_stn_transition!(transition, piece, source, destination)
      Stn.parse(transition)
    rescue ::StandardError => e
      raise ::ArgumentError, "Invalid STN format in 'diff' for #{piece} #{source}→#{destination}: #{e.message}"
    end
    private_class_method :validate_stn_transition!

    # Validate location format
    #
    # @param location [String] Location to validate
    # @param piece [String] Piece identifier (for error messages)
    # @raise [ArgumentError] If location format is invalid
    # @return [void]
    # @api private
    def self.validate_location!(location, piece)
      raise ::ArgumentError, "Location for #{piece} must be a String" unless location.is_a?(::String)

      valid = Cell.valid?(location) || Hand.reserve?(location)
      raise ::ArgumentError, "Invalid location format: #{location}" unless valid
    end
    private_class_method :validate_location!
  end
end
