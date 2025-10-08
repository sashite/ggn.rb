# frozen_string_literal: true

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
            # Create a new Engine
            #
            # @param possibilities [Array<Hash>] Movement possibilities data
            def initialize(*possibilities)
              @possibilities = possibilities
              freeze
            end

            # Evaluate movement against position and return valid transitions
            #
            # @param active_side [Symbol] Active player side (:first or :second)
            # @param squares [Hash{String => String, nil}] Board state where keys are CELL coordinates
            #   and values are QPI identifiers or nil for empty squares
            # @return [Array<Sashite::Stn::Transition>] Valid state transitions (may be empty)
            #
            # @example
            #   active_side = :first
            #   squares = {
            #     "e2" => "C:P",
            #     "e3" => nil,
            #     "e4" => nil
            #   }
            #   transitions = engine.where(active_side, squares)
            def where(active_side, squares)
              @possibilities.select do |possibility|
                satisfies_must?(possibility["must"], active_side, squares) &&
                  satisfies_deny?(possibility["deny"], active_side, squares)
              end.map do |possibility|
                Stn.parse(possibility["diff"])
              end
            end

            private

            # Check if all 'must' conditions are satisfied
            #
            # @param conditions [Hash] LCN conditions
            # @param active_side [Symbol] Active player side
            # @param squares [Hash] Board state
            # @return [Boolean]
            def satisfies_must?(conditions, active_side, squares)
              return true if conditions.empty?

              lcn_conditions = Lcn.parse(conditions)

              lcn_conditions.locations.all? do |location|
                expected_state = lcn_conditions[location]
                check_condition(location.to_s, expected_state, active_side, squares)
              end
            end

            # Check if all 'deny' conditions are not satisfied
            #
            # @param conditions [Hash] LCN conditions
            # @param active_side [Symbol] Active player side
            # @param squares [Hash] Board state
            # @return [Boolean]
            def satisfies_deny?(conditions, active_side, squares)
              return true if conditions.empty?

              lcn_conditions = Lcn.parse(conditions)

              lcn_conditions.locations.none? do |location|
                expected_state = lcn_conditions[location]
                check_condition(location.to_s, expected_state, active_side, squares)
              end
            end

            # Check if a location satisfies a condition
            #
            # @param location [String] Location to check (CELL coordinate)
            # @param expected_state [String] Expected state value
            # @param active_side [Symbol] Active player side
            # @param squares [Hash] Board state
            # @return [Boolean]
            def check_condition(location, expected_state, active_side, squares)
              actual_qpi = squares[location]

              case expected_state
              when "empty"
                actual_qpi.nil?
              when "enemy"
                actual_qpi && enemy?(actual_qpi, active_side)
              else
                # Expected state is a QPI identifier
                actual_qpi == expected_state
              end
            end

            # Check if a piece is an enemy relative to active side
            #
            # @param qpi_str [String] QPI identifier
            # @param active_side [Symbol] Active player side
            # @return [Boolean]
            def enemy?(qpi_str, active_side)
              piece_side = Qpi.parse(qpi_str).side
              piece_side != active_side
            end
          end
        end
      end
    end
  end
end
