# frozen_string_literal: true

module Sashite
  module Ggn
    class Ruleset
      class Source
        class Destination
          class Engine
            # Represents the result of a valid pseudo-legal move evaluation.
            #
            # A Transition encapsulates the changes that occur when a move is executed:
            # - Board state changes (pieces moving, appearing, or disappearing)
            # - Pieces gained in hand (from captures)
            # - Pieces dropped from hand (for drop moves)
            #
            # @example Basic move (pawn advance)
            #   transition = Transition.new(nil, nil, "e2" => nil, "e4" => "CHESS:P")
            #   transition.diff  # => { "e2" => nil, "e4" => "CHESS:P" }
            #   transition.gain  # => nil
            #   transition.drop  # => nil
            #
            # @example Capture with piece gain
            #   transition = Transition.new("CHESS:R", nil, "g7" => nil, "h8" => "CHESS:Q")
            #   transition.gain  # => "CHESS:R" (captured rook goes to hand)
            #
            # @example Piece drop from hand
            #   transition = Transition.new(nil, "SHOGI:P", "5e" => "SHOGI:P")
            #   transition.drop  # => "SHOGI:P" (pawn removed from hand)
            class Transition
              # @return [Hash<String, String|nil>] Board state changes after the move.
              #   Keys are square labels, values are piece identifiers or nil for empty squares.
              attr_reader :diff

              # @return [String, nil] Piece identifier added to the current player's hand,
              #   typically from a capture. Nil if no piece is gained.
              attr_reader :gain

              # @return [String, nil] Piece identifier removed from the current player's hand
              #   for drop moves. Nil if no piece is dropped.
              attr_reader :drop

              # Creates a new Transition with the specified changes.
              #
              # @param gain [String, nil] Piece gained in hand (usually from capture)
              # @param drop [String, nil] Piece dropped from hand (for drop moves)
              # @param diff [Hash] Board state changes as keyword arguments.
              #   Keys should be square labels, values should be piece identifiers or nil.
              #
              # @example Creating a simple move transition
              #   Transition.new(nil, nil, "e2" => nil, "e4" => "CHESS:P")
              #
              # @example Creating a capture transition
              #   Transition.new("CHESS:R", nil, "d4" => nil, "e5" => "CHESS:P")
              #
              # @example Creating a drop transition
              #   Transition.new(nil, "SHOGI:P", "3c" => "SHOGI:P")
              def initialize(gain, drop, **diff)
                @gain = gain
                @drop = drop
                @diff = diff

                freeze
              end

              # Checks if this transition involves gaining a piece.
              #
              # @return [Boolean] true if a piece is gained (typically from capture)
              #
              # @example
              #   transition.gain?  # => true if @gain is not nil
              def gain?
                !@gain.nil?
              end

              # Checks if this transition involves dropping a piece from hand.
              #
              # @return [Boolean] true if a piece is dropped from hand
              #
              # @example
              #   transition.drop?  # => true if @drop is not nil
              def drop?
                !@drop.nil?
              end
            end
          end
        end
      end
    end
  end
end
