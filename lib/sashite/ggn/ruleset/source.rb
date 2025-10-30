# frozen_string_literal: true

require_relative "source/destination"

module Sashite
  module Ggn
    class Ruleset
      # Represents movement possibilities for a piece type
      #
      # @see https://sashite.dev/specs/ggn/1.0.0/
      class Source
        # Create a new Source
        #
        # @param data [Hash] Sources data structure
        def initialize(data)
          @data = data

          freeze
        end

        # Specify the source location for the piece
        #
        # @param source [String] Source location (CELL coordinate or HAND "*")
        # @return [Destination] Destination selector object
        # @raise [KeyError] If source not found for this piece
        #
        # @example
        #   destination = source.from("e1")
        def from(source)
          raise ::KeyError, "Source not found: #{source}" unless source?(source)

          Destination.new(@data.fetch(source))
        end

        # Return all valid source locations for this piece
        #
        # @return [Array<String>] Source locations
        #
        # @example
        #   source.sources # => ["e1", "d1", "*"]
        def sources
          @data.keys
        end

        # Check if location is a valid source for this piece
        #
        # @param location [String] Source location
        # @return [Boolean]
        #
        # @example
        #   source.source?("e1") # => true
        def source?(location)
          @data.key?(location)
        end
      end
    end
  end
end
