# frozen_string_literal: true

require "sashite/cell"
require "sashite/epin"
require "sashite/feen"
require "sashite/lcn"
require "sashite/qpi"
require "sashite/stn"

module Sashite
  module Ggn
    class Ruleset
      class Source
        class Destination
          # Evaluates movement possibility under given position conditions
          #
          # @see https://sashite.dev/specs/ggn/1.0.0/
          class Engine
            # @return [String] The QPI piece identifier
            attr_reader :piece

            # @return [String] The source location
            attr_reader :source

            # @return [String] The destination location
            attr_reader :destination

            # @return [Array<Hash>] The movement possibilities
            attr_reader :data

            # Create a new Engine
            #
            # @param piece [String] QPI piece identifier
            # @param source [String] Source location
            # @param destination [String] Destination location
            # @param data [Array<Hash>] Movement possibilities data
            def initialize(piece, source, destination, data)
              @piece = piece
              @source = source
              @destination = destination
              @data = data

              freeze
            end

            # Evaluate movement against position and return valid transitions
            #
            # @param feen [String] Position in FEEN format
            # @return [Array<Sashite::Stn::Transition>] Valid state transitions (may be empty)
            #
            # @example
            #   transitions = engine.where(feen)
            def where(feen)
              position = Feen.parse(feen)
              reference_side = Qpi.parse(piece).side

              possibilities.select do |possibility|
                satisfies_must?(possibility["must"], position, reference_side) &&
                  satisfies_deny?(possibility["deny"], position, reference_side)
              end.map do |possibility|
                Stn.parse(possibility["diff"])
              end
            end

            # Return raw movement possibility rules
            #
            # @return [Array<Hash>] Movement possibility specifications
            #
            # @example
            #   engine.possibilities
            #   # => [{ "must" => {...}, "deny" => {...}, "diff" => {...} }]
            def possibilities
              data
            end

            private

            # Check if all 'must' conditions are satisfied
            #
            # @param conditions [Hash] LCN conditions
            # @param position [Feen::Position] Current position
            # @param reference_side [Symbol] Reference piece side (:first or :second)
            # @return [Boolean]
            def satisfies_must?(conditions, position, reference_side)
              return true if conditions.empty?

              lcn_conditions = Lcn.parse(conditions)

              lcn_conditions.locations.all? do |location|
                expected_state = lcn_conditions[location]
                check_condition(location, expected_state, position, reference_side)
              end
            end

            # Check if all 'deny' conditions are not satisfied
            #
            # @param conditions [Hash] LCN conditions
            # @param position [Feen::Position] Current position
            # @param reference_side [Symbol] Reference piece side (:first or :second)
            # @return [Boolean]
            def satisfies_deny?(conditions, position, reference_side)
              return true if conditions.empty?

              lcn_conditions = Lcn.parse(conditions)

              lcn_conditions.locations.none? do |location|
                expected_state = lcn_conditions[location]
                check_condition(location, expected_state, position, reference_side)
              end
            end

            # Check if a location satisfies a condition
            #
            # @param location [Symbol] Location to check
            # @param expected_state [String] Expected state value
            # @param position [Feen::Position] Current position
            # @param reference_side [Symbol] Reference piece side
            # @return [Boolean]
            def check_condition(location, expected_state, position, reference_side)
              location_str = location.to_s
              epin_value = get_piece_at(position, location_str)

              case expected_state
              when "empty"
                epin_value.nil?
              when "enemy"
                epin_value && is_enemy?(epin_value, reference_side)
              else
                # Expected state is a QPI identifier - compare EPIN parts
                epin_value && matches_qpi?(epin_value, expected_state)
              end
            end

            # Get piece at a board location
            #
            # @param position [Feen::Position] Current position
            # @param location [String] Board location (CELL coordinate)
            # @return [Object, nil] EPIN value or nil if empty
            def get_piece_at(position, location)
              indices = Cell.to_indices(location)
              col_index = indices[0]
              row_index_from_bottom = indices[1]

              # FEEN ranks are stored top-to-bottom, but CELL indices are bottom-up
              # Need to invert the rank index
              total_ranks = position.placement.ranks.size
              rank_index = total_ranks - 1 - row_index_from_bottom

              position.placement.ranks[rank_index][col_index]
            end

            # Check if a piece is an enemy relative to reference side
            #
            # @param epin_value [Object] EPIN value from ranks
            # @param reference_side [Symbol] Reference side
            # @return [Boolean]
            def is_enemy?(epin_value, reference_side)
              epin_str = epin_value.to_s
              piece_side = epin_str.match?(/[A-Z]/) ? :first : :second
              piece_side != reference_side
            end

            # Check if EPIN matches QPI identifier
            #
            # @param epin_value [Object] EPIN value from ranks
            # @param qpi_str [String] QPI identifier to match
            # @return [Boolean]
            def matches_qpi?(epin_value, qpi_str)
              epin_str = epin_value.to_s

              # Extract EPIN part from QPI (after the colon)
              qpi_parts = qpi_str.split(":")
              return false if qpi_parts.length != 2

              expected_epin = qpi_parts[1]

              # Direct comparison of EPIN strings
              epin_str == expected_epin
            end
          end
        end
      end
    end
  end
end
