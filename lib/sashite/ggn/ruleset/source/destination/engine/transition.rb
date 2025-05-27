# frozen_string_literal: true

module Sashite
  module Ggn
    class Ruleset
      class Source
        class Destination
          class Engine
            # Represents the result of a valid pseudo-legal move evaluation.
            #
            # A Transition encapsulates the changes that occur when a move is executed
            # on the game board. Since GGN focuses exclusively on board-to-board
            # transformations, a Transition only contains board state changes: pieces
            # moving, appearing, or disappearing on the board.
            #
            # @example Basic move (pawn advance)
            #   transition = Transition.new("e2" => nil, "e4" => "CHESS:P")
            #   transition.diff  # => { "e2" => nil, "e4" => "CHESS:P" }
            #
            # @example Capture (piece takes enemy piece)
            #   transition = Transition.new("d4" => nil, "e5" => "CHESS:P")
            #   transition.diff  # => { "d4" => nil, "e5" => "CHESS:P" }
            #
            # @example Complex move (castling with king and rook)
            #   transition = Transition.new(
            #     "e1" => nil, "f1" => "CHESS:R", "g1" => "CHESS:K", "h1" => nil
            #   )
            #   transition.diff  # => { "e1" => nil, "f1" => "CHESS:R", "g1" => "CHESS:K", "h1" => nil }
            #
            # @example Promotion (pawn becomes queen)
            #   transition = Transition.new("e7" => nil, "e8" => "CHESS:Q")
            #   transition.diff  # => { "e7" => nil, "e8" => "CHESS:Q" }
            class Transition
              # @return [Hash<String, String|nil>] Board state changes after the move.
              #   Keys are square labels, values are piece identifiers or nil for empty squares.
              attr_reader :diff

              # Creates a new Transition with the specified board changes.
              #
              # @param diff [Hash] Board state changes as keyword arguments.
              #   Keys should be square labels, values should be piece identifiers or nil.
              #
              # @example Creating a simple move transition
              #   Transition.new("e2" => nil, "e4" => "CHESS:P")
              #
              # @example Creating a capture transition
              #   Transition.new("d4" => nil, "e5" => "CHESS:P")
              #
              # @example Creating a complex multi-square transition (castling)
              #   Transition.new(
              #     "e1" => nil,        # King leaves e1
              #     "f1" => "CHESS:R",  # Rook moves to f1
              #     "g1" => "CHESS:K",  # King moves to g1
              #     "h1" => nil         # Rook leaves h1
              #   )
              #
              # @example Creating a promotion transition
              #   Transition.new("e7" => nil, "e8" => "CHESS:Q")
              #
              # @example Creating an en passant capture
              #   Transition.new(
              #     "d5" => nil,        # Attacking pawn leaves d5
              #     "e5" => nil,        # Captured pawn removed from e5
              #     "e6" => "CHESS:P"   # Attacking pawn lands on e6
              #   )
              def initialize(**diff)
                @diff = diff

                freeze
              end

              # This class remains intentionally simple and rule-agnostic.
              # Any interpretation of what constitutes a "capture" or "promotion"
              # is left to higher-level game logic, maintaining GGN's neutrality.
            end
          end
        end
      end
    end
  end
end
