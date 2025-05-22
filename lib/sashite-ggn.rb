# frozen_string_literal: true

# Sashité - Abstract Strategy Board Games Notation Library
#
# This library provides a comprehensive implementation of the General Gameplay Notation (GGN)
# specification, which is a rule-agnostic, JSON-based format for describing pseudo-legal
# moves in abstract strategy board games.
#
# GGN works alongside other Sashité specifications:
# - GAN (General Actor Notation): Unique piece identifiers
# - FEEN (Forsyth-Edwards Enhanced Notation): Board position representation
# - PMN (Portable Move Notation): Move sequence representation
#
# @author Sashité <https://sashite.com/>
# @version 1.0.0
# @see https://sashite.dev/documents/ggn/1.0.0/ GGN Specification
# @see https://github.com/sashite/ggn.rb Official Ruby implementation
#
# @example Basic usage with a chess pawn double move
#   # Load GGN data from file
#   require "sashite/ggn"
#
#   piece_data = Sashite::Ggn.load_file("chess_moves.json")
#   engine = piece_data.select("CHESS:P").from("e2").to("e4")
#
#   # Check if the move is valid given current board state
#   board_state = {
#     "e2" => "CHESS:P",  # White pawn on e2
#     "e3" => nil,        # Empty square
#     "e4" => nil         # Empty square
#   }
#
#   result = engine.evaluate(board_state, {}, "CHESS")
#
#   if result
#     puts "Move is valid!"
#     puts "Board changes: #{result.diff}"
#     # => { "e2" => nil, "e4" => "CHESS:P" }
#     puts "Piece gained: #{result.gain}" # => nil (no capture)
#     puts "Piece dropped: #{result.drop}" # => nil (not a drop move)
#   else
#     puts "Move is not valid under current conditions"
#   end
#
# @example Piece drops in Shogi
#   # Shogi allows captured pieces to be dropped back onto the board
#   piece_data = Sashite::Ggn.load_file("shogi_moves.json")
#   engine = piece_data.select("SHOGI:P").from("*").to("5e")
#
#   # Player has captured pawns available
#   captures = { "SHOGI:P" => 2 }
#
#   # Current board state (5th file is clear of unpromoted pawns)
#   board_state = {
#     "5e" => nil,     # Target square is empty
#     "5a" => nil, "5b" => nil, "5c" => nil, "5d" => nil,
#     "5f" => nil, "5g" => nil, "5h" => nil, "5i" => nil
#   }
#
#   result = engine.evaluate(board_state, captures, "SHOGI")
#
#   if result
#     puts "Pawn drop is valid!"
#     puts "Board changes: #{result.diff}"  # => { "5e" => "SHOGI:P" }
#     puts "Piece dropped from hand: #{result.drop}"  # => "SHOGI:P"
#   end
#
# @example Captures with piece promotion
#   # A chess pawn capturing and promoting to queen
#   piece_data = Sashite::Ggn.load_file("chess_moves.json")
#   engine = piece_data.select("CHESS:P").from("g7").to("h8")
#
#   # Board with enemy piece on h8
#   board_state = {
#     "g7" => "CHESS:P",  # Our pawn ready to promote
#     "h8" => "chess:r"   # Enemy rook (lowercase = opponent)
#   }
#
#   result = engine.evaluate(board_state, {}, "CHESS")
#
#   if result
#     puts "Pawn promotes and captures!"
#     puts "Final position: #{result.diff}"
#     # => { "g7" => nil, "h8" => "CHESS:Q" }
#     puts "Captured piece: #{result.gain}"  # => nil (no capture _in hand_)
#   end
#
# @example Loading GGN data from different sources
#   # From file
#   piece_data = Sashite::Ggn.load_file("moves.json")
#
#   # From JSON string
#   json_string = '{"CHESS:K": {"e1": {"e2": [{"perform": {"e1": null, "e2": "CHESS:K"}}]}}}'
#   piece_data = Sashite::Ggn.load_string(json_string)
#
#   # From Hash
#   ggn_hash = { "CHESS:K" => { "e1" => { "e2" => [{ "perform" => { "e1" => nil, "e2" => "CHESS:K" } }] } } }
#   piece_data = Sashite::Ggn.load_hash(ggn_hash)
module Sashite
  # Base namespace for all Sashité notation libraries.
  #
  # Sashité provides a comprehensive suite of specifications and implementations
  # for representing abstract strategy board games in a rule-agnostic manner.
  # This allows for unified game engines, cross-game analysis, and hybrid
  # game variants.
  #
  # @see https://sashite.com/ Official Sashité website
  # @see https://sashite.dev/ Developer documentation and specifications
end

# Load the main GGN implementation
require_relative "sashite/ggn"
