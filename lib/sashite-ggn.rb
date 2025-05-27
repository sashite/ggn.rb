# frozen_string_literal: true

# Sashité - Abstract Strategy Board Games Notation Library
#
# This library provides a comprehensive implementation of the General Gameplay Notation (GGN)
# specification, which is a rule-agnostic, JSON-based format for describing pseudo-legal
# moves in abstract strategy board games.
#
# GGN focuses exclusively on board-to-board transformations: pieces moving, capturing,
# or transforming on the game board. Hand management, drops, and captures-to-hand are
# outside the scope of this specification.
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
#   transitions = engine.where(board_state, "CHESS")
#
#   if transitions.any?
#     transition = transitions.first
#     puts "Move is valid!"
#     puts "Board changes: #{transition.diff}"
#     # => { "e2" => nil, "e4" => "CHESS:P" }
#   else
#     puts "Move is not valid under current conditions"
#   end
#
# @example Piece promotion with multiple variants
#   # Chess pawn promotion offers multiple choices
#   piece_data = Sashite::Ggn.load_file("chess_moves.json")
#   engine = piece_data.select("CHESS:P").from("e7").to("e8")
#
#   # Board with pawn ready to promote
#   board_state = {
#     "e7" => "CHESS:P",  # White pawn on 7th rank
#     "e8" => nil         # Empty promotion square
#   }
#
#   transitions = engine.where(board_state, "CHESS")
#
#   transitions.each_with_index do |transition, i|
#     promoted_piece = transition.diff["e8"]
#     puts "Promotion choice #{i + 1}: #{promoted_piece}"
#   end
#   # Output: CHESS:Q, CHESS:R, CHESS:B, CHESS:N
#
# @example Complex multi-square moves like castling
#   # Castling involves both king and rook movement
#   piece_data = Sashite::Ggn.load_file("chess_moves.json")
#   engine = piece_data.select("CHESS:K").from("e1").to("g1")
#
#   # Board state allowing kingside castling
#   board_state = {
#     "e1" => "CHESS:K",  # King on starting square
#     "f1" => nil,        # Empty square
#     "g1" => nil,        # Empty destination
#     "h1" => "CHESS:R"   # Rook on starting square
#   }
#
#   transitions = engine.where(board_state, "CHESS")
#
#   if transitions.any?
#     transition = transitions.first
#     puts "Castling is possible!"
#     puts "Final position: #{transition.diff}"
#     # => { "e1" => nil, "f1" => "CHESS:R", "g1" => "CHESS:K", "h1" => nil }
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
#
# @example Generating all possible moves
#   # Get all pseudo-legal moves for the current position
#   board_state = {
#     "e1" => "CHESS:K", "d1" => "CHESS:Q", "a1" => "CHESS:R",
#     "e2" => "CHESS:P", "d2" => "CHESS:P"
#   }
#
#   all_moves = piece_data.pseudo_legal_transitions(board_state, "CHESS")
#
#   all_moves.each do |actor, origin, target, transitions|
#     puts "#{actor}: #{origin} → #{target} (#{transitions.size} variants)"
#   end
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
