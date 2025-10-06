# frozen_string_literal: true

require_relative "destination/engine"

module Sashite
  module Ggn
    class Ruleset
      class Source
        # Represents movement possibilities from a specific source
        #
        # @see https://sashite.dev/specs/ggn/1.0.0/
        class Destination
          # @return [String] The QPI piece identifier
          attr_reader :piece

          # @return [String] The source location
          attr_reader :source

          # @return [Hash] The destinations data
          attr_reader :data

          # Create a new Destination
          #
          # @param piece [String] QPI piece identifier
          # @param source [String] Source location
          # @param data [Hash] Destinations data structure
          def initialize(piece, source, data)
            @piece = piece
            @source = source
            @data = data

            freeze
          end

          # Specify the destination location
          #
          # @param destination [String] Destination location (CELL coordinate or HAND "*")
          # @return [Engine] Movement evaluation engine
          # @raise [KeyError] If destination not found from this source
          #
          # @example
          #   engine = destination.to("e2")
          def to(destination)
            raise ::KeyError, "Destination not found: #{destination}" unless destination?(destination)

            Engine.new(piece, source, destination, data.fetch(destination))
          end

          # Return all valid destinations from this source
          #
          # @return [Array<String>] Destination locations
          #
          # @example
          #   destination.destinations # => ["d1", "d2", "e2", "f2", "f1"]
          def destinations
            data.keys
          end

          # Check if location is a valid destination from this source
          #
          # @param location [String] Destination location
          # @return [Boolean]
          #
          # @example
          #   destination.destination?("e2") # => true
          def destination?(location)
            data.key?(location)
          end
        end
      end
    end
  end
end
