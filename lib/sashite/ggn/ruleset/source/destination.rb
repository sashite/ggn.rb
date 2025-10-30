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
          # Create a new Destination
          #
          # @param data [Hash] Destinations data structure
          def initialize(data)
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

            Engine.new(*@data.fetch(destination))
          end

          # Return all valid destinations from this source
          #
          # @return [Array<String>] Destination locations
          #
          # @example
          #   destination.destinations # => ["d1", "d2", "e2", "f2", "f1"]
          def destinations
            @data.keys
          end

          # Check if location is a valid destination from this source
          #
          # @param location [String] Destination location
          # @return [Boolean]
          #
          # @example
          #   destination.destination?("e2") # => true
          def destination?(location)
            @data.key?(location)
          end
        end
      end
    end
  end
end
