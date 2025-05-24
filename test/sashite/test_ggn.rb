# frozen_string_literal: true

require_relative "../../lib/sashite-ggn"
require 'tempfile'
require 'json'

puts "Testing Sashite::Ggn module..."

# Helper method to create temporary JSON files for testing
def create_temp_ggn_file(data)
  file = Tempfile.new(['test_ggn', '.json'])
  file.write(JSON.generate(data))
  file.close
  file
end

# Sample valid GGN data for testing
VALID_GGN_DATA = {
  "CHESS:P" => {
    "e2" => {
      "e4" => [
        {
          "require" => {
            "e3" => "empty",
            "e4" => "empty"
          },
          "perform" => {
            "e2" => nil,
            "e4" => "CHESS:P"
          }
        }
      ],
      "e3" => [
        {
          "require" => { "e3" => "empty" },
          "perform" => {
            "e2" => nil,
            "e3" => "CHESS:P"
          }
        }
      ]
    }
  },
  "CHESS:K" => {
    "e1" => {
      "e2" => [
        {
          "require" => { "e2" => "empty" },
          "perform" => { "e1" => nil, "e2" => "CHESS:K" }
        }
      ],
      "f1" => [
        {
          "require" => { "f1" => "empty" },
          "perform" => { "e1" => nil, "f1" => "CHESS:K" }
        }
      ]
    }
  },
  "SHOGI:P" => {
    "*" => {
      "5e" => [
        {
          "require" => { "5e" => "empty" },
          "prevent" => {
            "5a" => "SHOGI:P", "5b" => "SHOGI:P", "5c" => "SHOGI:P",
            "5d" => "SHOGI:P", "5f" => "SHOGI:P", "5g" => "SHOGI:P"
          },
          "perform" => { "5e" => "SHOGI:P" },
          "drop" => "SHOGI:P"
        }
      ]
    }
  }
}.freeze

# Invalid GGN data for testing validation
INVALID_GGN_DATA = {
  "INVALID" => {
    "e2" => {
      "e4" => [
        {
          # Missing required "perform" field
          "require" => { "e4" => "empty" }
        }
      ]
    }
  }
}.freeze

# Test Sashite::Ggn.load_string
puts "  Testing Sashite::Ggn.load_string..."

# Valid JSON string
valid_json = JSON.generate(VALID_GGN_DATA)
piece = Sashite::Ggn.load_string(valid_json)
raise unless piece.is_a?(Sashite::Ggn::Piece)
puts "    ✓ Successfully loads valid GGN string"

# Invalid JSON string
begin
  Sashite::Ggn.load_string("{invalid json")
  raise "Should have raised ValidationError"
rescue Sashite::Ggn::ValidationError => e
  raise unless e.message.include?("Invalid JSON")
end
puts "    ✓ Raises ValidationError for invalid JSON"

# Invalid GGN structure (with validation)
begin
  invalid_json = JSON.generate(INVALID_GGN_DATA)
  Sashite::Ggn.load_string(invalid_json, validate: true)
  raise "Should have raised ValidationError"
rescue Sashite::Ggn::ValidationError => e
  raise unless e.message.include?("validation error")
end
puts "    ✓ Raises ValidationError for invalid GGN structure"

# Invalid GGN structure (without validation)
invalid_json = JSON.generate(INVALID_GGN_DATA)
piece = Sashite::Ggn.load_string(invalid_json, validate: false)
raise unless piece.is_a?(Sashite::Ggn::Piece)
puts "    ✓ Accepts invalid GGN when validation is disabled"

# Test Sashite::Ggn.load_hash
puts "  Testing Sashite::Ggn.load_hash..."

# Valid hash
piece = Sashite::Ggn.load_hash(VALID_GGN_DATA)
raise unless piece.is_a?(Sashite::Ggn::Piece)
puts "    ✓ Successfully loads valid GGN hash"

# Non-hash input
begin
  Sashite::Ggn.load_hash("not a hash")
  raise "Should have raised ValidationError"
rescue Sashite::Ggn::ValidationError => e
  raise unless e.message.include?("Expected Hash")
end
puts "    ✓ Raises ValidationError for non-hash input"

# Test Sashite::Ggn.load_file
puts "  Testing Sashite::Ggn.load_file..."

# Valid file
temp_file = create_temp_ggn_file(VALID_GGN_DATA)
begin
  piece = Sashite::Ggn.load_file(temp_file.path)
  raise unless piece.is_a?(Sashite::Ggn::Piece)
ensure
  temp_file.unlink
end
puts "    ✓ Successfully loads valid GGN file"

# Non-existent file
begin
  Sashite::Ggn.load_file("non_existent_file.json")
  raise "Should have raised ValidationError"
rescue Sashite::Ggn::ValidationError => e
  raise unless e.message.include?("File not found")
end
puts "    ✓ Raises ValidationError for non-existent file"

# Invalid JSON file
temp_file = Tempfile.new(['invalid', '.json'])
temp_file.write("{invalid json")
temp_file.close
begin
  Sashite::Ggn.load_file(temp_file.path)
  raise "Should have raised ValidationError"
rescue Sashite::Ggn::ValidationError => e
  raise unless e.message.include?("Invalid JSON")
ensure
  temp_file.unlink
end
puts "    ✓ Raises ValidationError for invalid JSON file"

# Test validation methods
puts "  Testing validation methods..."

# Test valid?
raise unless Sashite::Ggn.valid?(VALID_GGN_DATA)
raise if Sashite::Ggn.valid?(INVALID_GGN_DATA)
puts "    ✓ valid? correctly identifies valid/invalid data"

# Test validate!
begin
  result = Sashite::Ggn.validate!(VALID_GGN_DATA)
  raise unless result == true
rescue => e
  raise "validate! should not raise for valid data: #{e}"
end

begin
  Sashite::Ggn.validate!(INVALID_GGN_DATA)
  raise "validate! should raise for invalid data"
rescue Sashite::Ggn::ValidationError
  # Expected
end
puts "    ✓ validate! works correctly"

# Test validation_errors
errors = Sashite::Ggn.validation_errors(VALID_GGN_DATA)
raise unless errors.empty?

errors = Sashite::Ggn.validation_errors(INVALID_GGN_DATA)
raise if errors.empty?
puts "    ✓ validation_errors returns appropriate results"

# Test Piece class
puts "  Testing Sashite::Ggn::Piece..."

piece = Sashite::Ggn::Piece.new(VALID_GGN_DATA)
puts "    ✓ Piece constructor works correctly"

# Test select method
chess_pawn_source = piece.select("CHESS:P")
raise unless chess_pawn_source.is_a?(Sashite::Ggn::Piece::Source)

begin
  piece.select("NONEXISTENT:X")
  raise "Should have raised KeyError"
rescue KeyError
  # Expected
end
puts "    ✓ select method works correctly"

# Test invalid constructor
begin
  Sashite::Ggn::Piece.new("not a hash")
  raise "Should have raised ArgumentError"
rescue ArgumentError => e
  raise unless e.message.include?("Expected Hash")
end
puts "    ✓ Constructor validates input type"

# Test pseudo_legal_moves method
puts "  Testing Sashite::Ggn::Piece#pseudo_legal_moves..."

# Test basic functionality with valid board state
board_state = {
  "e2" => "CHESS:P",  # Pawn on e2
  "e1" => "CHESS:K",  # King on e1
  "e3" => nil,        # Empty squares
  "e4" => nil,
  "f1" => nil
}
moves = piece.pseudo_legal_moves(board_state, {}, "CHESS")

# Should find pawn moves and king moves
expected_moves = [["e2", "e4"], ["e2", "e3"], ["e1", "f1"]]
raise unless moves.sort == expected_moves.sort
puts "    ✓ Returns correct moves for valid board state"

# Test with Shogi drops
drop_board = {
  "5e" => nil,
  "5a" => nil, "5b" => nil, "5c" => nil, "5d" => nil,
  "5f" => nil, "5g" => nil
}
drop_captures = { "SHOGI:P" => 1 }
drop_moves = piece.pseudo_legal_moves(drop_board, drop_captures, "SHOGI")

raise unless drop_moves.include?(["*", "5e"])
puts "    ✓ Correctly includes drop moves when pieces available in hand"

# Test with no valid moves (wrong player)
no_moves = piece.pseudo_legal_moves(board_state, {}, "shogi")  # lowercase = second player
raise unless no_moves.empty?
puts "    ✓ Returns empty array when no pieces belong to current player"

# Test parameter validation
begin
  piece.pseudo_legal_moves("not a hash", {}, "CHESS")
  raise "Should have raised ArgumentError"
rescue ArgumentError => e
  raise unless e.message.include?("board_state must be a Hash")
end

begin
  piece.pseudo_legal_moves({}, "not a hash", "CHESS")
  raise "Should have raised ArgumentError"
rescue ArgumentError => e
  raise unless e.message.include?("captures must be a Hash")
end

begin
  piece.pseudo_legal_moves({}, {}, 123)
  raise "Should have raised ArgumentError"
rescue ArgumentError => e
  raise unless e.message.include?("turn must be a String")
end

begin
  piece.pseudo_legal_moves({}, {}, "")
  raise "Should have raised ArgumentError"
rescue ArgumentError => e
  raise unless e.message.include?("turn cannot be empty")
end
puts "    ✓ Validates parameters correctly"

# Test performance optimization (early pruning)
# Create a board state where pieces are missing but optimization should skip checking
optimization_board = {
  "e2" => nil,  # No piece here, but optimization should skip before checking
  "e1" => nil
}
optimized_moves = piece.pseudo_legal_moves(optimization_board, {}, "CHESS")
raise unless optimized_moves.empty?
puts "    ✓ Performance optimization works (early pruning when pieces missing)"

# Test Source class
puts "  Testing Sashite::Ggn::Piece::Source..."

source = piece.select("CHESS:P")
puts "    ✓ Basic Source instantiation works"

# Test from method
destination = source.from("e2")
raise unless destination.is_a?(Sashite::Ggn::Piece::Source::Destination)

begin
  source.from("invalid")
  raise "Should have raised KeyError"
rescue KeyError
  # Expected
end
puts "    ✓ Source from method works correctly"

# Test invalid constructor
begin
  Sashite::Ggn::Piece::Source.new("not a hash", actor: "CHESS:P")
  raise "Should have raised ArgumentError"
rescue ArgumentError => e
  raise unless e.message.include?("Expected Hash")
end
puts "    ✓ Source constructor validates input type"

# Test Destination class
puts "  Testing Sashite::Ggn::Piece::Source::Destination..."

destination = source.from("e2")
puts "    ✓ Basic Destination instantiation works"

# Test to method
engine = destination.to("e4")
raise unless engine.is_a?(Sashite::Ggn::Piece::Source::Destination::Engine)

begin
  destination.to("invalid")
  raise "Should have raised KeyError"
rescue KeyError
  # Expected
end
puts "    ✓ Destination to method works correctly"

# Test invalid constructor
begin
  Sashite::Ggn::Piece::Source::Destination.new("not a hash", actor: "CHESS:P", origin: "e2")
  raise "Should have raised ArgumentError"
rescue ArgumentError => e
  raise unless e.message.include?("Expected Hash")
end
puts "    ✓ Destination constructor validates input type"

# Test Engine class
puts "  Testing Sashite::Ggn::Piece::Source::Destination::Engine..."

engine = destination.to("e4")
puts "    ✓ Basic Engine instantiation works"

# Test where method with valid move (piece exists at origin)
board_state = {
  "e2" => "CHESS:P",  # Piece must be at origin
  "e3" => nil,
  "e4" => nil
}
result = engine.where(board_state, {}, "CHESS")
raise unless result.is_a?(Sashite::Ggn::Piece::Source::Destination::Engine::Transition)
raise unless result.diff == { "e2" => nil, "e4" => "CHESS:P" }
raise unless result.gain.nil?
raise unless result.drop.nil?
puts "    ✓ where returns valid Transition for valid move"

# Test where method with blocked move
blocked_board = {
  "e2" => "CHESS:P",
  "e3" => "CHESS:N",  # Blocked by knight
  "e4" => nil
}
result = engine.where(blocked_board, {}, "CHESS")
raise unless result.nil?
puts "    ✓ where returns nil for blocked move"

# Test where with wrong piece at origin
wrong_piece_board = {
  "e2" => "CHESS:K",  # Wrong piece type
  "e3" => nil,
  "e4" => nil
}
result = engine.where(wrong_piece_board, {}, "CHESS")
raise unless result.nil?
puts "    ✓ where returns nil when wrong piece at origin"

# Test where with missing piece at origin
no_piece_board = {
  "e2" => nil,  # No piece at origin
  "e3" => nil,
  "e4" => nil
}
result = engine.where(no_piece_board, {}, "CHESS")
raise unless result.nil?
puts "    ✓ where returns nil when no piece at origin"

# Test where with opponent's piece
opponent_piece_board = {
  "e2" => "chess:p",  # Opponent's piece (lowercase)
  "e3" => nil,
  "e4" => nil
}
result = engine.where(opponent_piece_board, {}, "CHESS")
raise unless result.nil?
puts "    ✓ where returns nil for opponent's piece"

# Test where with invalid arguments
begin
  engine.where("not a hash", {}, "CHESS")
  raise "Should have raised ArgumentError"
rescue ArgumentError => e
  raise unless e.message.include?("board_state must be a Hash")
end

begin
  engine.where({}, "not a hash", "CHESS")
  raise "Should have raised ArgumentError"
rescue ArgumentError => e
  raise unless e.message.include?("captures must be a Hash")
end

begin
  engine.where({}, {}, 123)
  raise "Should have raised ArgumentError"
rescue ArgumentError => e
  raise unless e.message.include?("turn must be a String")
end
puts "    ✓ where validates argument types"

# Test invalid constructor arguments
begin
  Sashite::Ggn::Piece::Source::Destination::Engine.new(actor: 123, origin: "e2", target: "e4")
  raise "Should have raised ArgumentError"
rescue ArgumentError => e
  raise unless e.message.include?("actor must be a String")
end

begin
  Sashite::Ggn::Piece::Source::Destination::Engine.new(actor: "CHESS:P", origin: 123, target: "e4")
  raise "Should have raised ArgumentError"
rescue ArgumentError => e
  raise unless e.message.include?("origin must be a String")
end

begin
  Sashite::Ggn::Piece::Source::Destination::Engine.new(actor: "CHESS:P", origin: "e2", target: 123)
  raise "Should have raised ArgumentError"
rescue ArgumentError => e
  raise unless e.message.include?("target must be a String")
end
puts "    ✓ Engine constructor validates input"

# Test Transition class
puts "  Testing Sashite::Ggn::Piece::Source::Destination::Engine::Transition..."

transition = Sashite::Ggn::Piece::Source::Destination::Engine::Transition.new(
  "CHESS:R",
  "CHESS:P",
  "e2" => nil,
  "e4" => "CHESS:Q"
)

# Test basic attributes
raise unless transition.gain == "CHESS:R"
raise unless transition.drop == "CHESS:P"
raise unless transition.diff == { "e2" => nil, "e4" => "CHESS:Q" }
puts "    ✓ Basic Transition attributes work correctly"

# Test utility methods
raise unless transition.gain?
raise unless transition.drop?
puts "    ✓ Transition utility methods work correctly"

# Test transition without gain/drop
simple_transition = Sashite::Ggn::Piece::Source::Destination::Engine::Transition.new(
  nil, nil, "e2" => nil, "e3" => "CHESS:P"
)
raise if simple_transition.gain?
raise if simple_transition.drop?
puts "    ✓ Simple Transition works correctly"

# Test empty transition
empty_transition = Sashite::Ggn::Piece::Source::Destination::Engine::Transition.new(nil, nil)
raise if empty_transition.gain?
raise if empty_transition.drop?
raise unless empty_transition.diff.empty?
puts "    ✓ Empty Transition works correctly"

# Test Shogi drop scenario
puts "  Testing Shogi drop scenario..."

shogi_source = piece.select("SHOGI:P")
drop_destination = shogi_source.from("*")
drop_engine = drop_destination.to("5e")

# Valid drop (piece available in hand, no pawns on 5th file)
drop_board = {
  "5e" => nil,
  "5a" => nil, "5b" => nil, "5c" => nil, "5d" => nil,
  "5f" => nil, "5g" => nil
}
captures_with_pawn = { "SHOGI:P" => 1 }  # Pawn available in hand
drop_result = drop_engine.where(drop_board, captures_with_pawn, "SHOGI")
raise unless drop_result
raise unless drop_result.drop == "SHOGI:P"
raise unless drop_result.diff == { "5e" => "SHOGI:P" }
puts "    ✓ Valid Shogi pawn drop works"

# Invalid drop (no pawn in hand)
drop_result = drop_engine.where(drop_board, {}, "SHOGI")  # No pieces in hand
raise unless drop_result.nil?
puts "    ✓ Invalid Shogi pawn drop (no piece in hand) correctly rejected"

# Invalid drop (pawn already on file)
blocked_drop_board = drop_board.dup
blocked_drop_board["5c"] = "SHOGI:P"  # Pawn already on file
drop_result = drop_engine.where(blocked_drop_board, captures_with_pawn, "SHOGI")
raise unless drop_result.nil?
puts "    ✓ Invalid Shogi pawn drop (blocked file) correctly rejected"

# Test promoted piece drop from base form in hand
puts "  Testing promoted piece drop from base form in hand..."

promoted_drop_ggn_data = {
  "SHOGI:+P" => {  # Promoted pawn drop (tokin)
    "*" => {
      "5e" => [
        {
          "require" => { "5e" => "empty" },
          "perform" => { "5e" => "SHOGI:+P" },  # Places promoted pawn on board
          "drop" => "SHOGI:P"  # But removes base form from hand
        }
      ]
    }
  }
}

promoted_drop_piece = Sashite::Ggn::Piece.new(promoted_drop_ggn_data)
promoted_drop_engine = promoted_drop_piece.select("SHOGI:+P").from("*").to("5e")

# Valid promoted drop (base form available in hand)
# This tests the key behavior: requesting "SHOGI:+P" drop while having "SHOGI:P" in hand
empty_board = { "5e" => nil }
captures_with_base_pawn = { "SHOGI:P" => 1 }  # Only base form in hand

promoted_drop_result = promoted_drop_engine.where(empty_board, captures_with_base_pawn, "SHOGI")
raise unless promoted_drop_result
raise unless promoted_drop_result.drop == "SHOGI:P"  # Base form removed from hand
raise unless promoted_drop_result.diff == { "5e" => "SHOGI:+P" }  # Promoted form placed on board
puts "    ✓ Can drop promoted piece when base form is available in hand"

# Invalid promoted drop (no base form in hand)
promoted_drop_result = promoted_drop_engine.where(empty_board, {}, "SHOGI")
raise unless promoted_drop_result.nil?
puts "    ✓ Cannot drop promoted piece when base form not available in hand"

# Invalid promoted drop (promoted form in hand - this should raise ArgumentError per GGN spec)
captures_with_promoted_only = { "SHOGI:+P" => 1 }  # Invalid: promoted form in hand
begin
  promoted_drop_result = promoted_drop_engine.where(empty_board, captures_with_promoted_only, "SHOGI")
  raise "Should have raised ArgumentError for promoted piece in captures"
rescue ArgumentError => e
  raise unless e.message.include?("Invalid base GAN identifier in captures")
  raise unless e.message.include?("SHOGI:+P")
end
puts "    ✓ Correctly rejects promoted piece identifiers in captures (per GGN spec)"

# Verify the base piece extraction logic works correctly
test_engine = promoted_drop_engine
extracted_base = test_engine.send(:extract_base_piece, "SHOGI:+P")
raise unless extracted_base == "SHOGI:P"
puts "    ✓ Base piece extraction correctly strips modifiers from promoted pieces"

# Test with other modifiers for completeness
extracted_base = test_engine.send(:extract_base_piece, "GAME:-X")
raise unless extracted_base == "GAME:X"
extracted_base = test_engine.send(:extract_base_piece, "GAME:Y'")
raise unless extracted_base == "GAME:Y"
extracted_base = test_engine.send(:extract_base_piece, "GAME:+Z'")
raise unless extracted_base == "GAME:Z"
puts "    ✓ Base piece extraction works with all modifier combinations"

# Test promoted piece handling
puts "  Testing promoted piece handling..."

promoted_ggn_data = {
  "SHOGI:+P" => {  # Promoted pawn
    "5e" => {
      "5f" => [
        {
          "require" => { "5f" => "empty" },
          "perform" => { "5e" => nil, "5f" => "SHOGI:+P" }
        }
      ]
    }
  }
}

promoted_piece = Sashite::Ggn::Piece.new(promoted_ggn_data)
promoted_source = promoted_piece.select("SHOGI:+P")
promoted_destination = promoted_source.from("5e")
promoted_engine = promoted_destination.to("5f")

# Valid move with promoted piece
promoted_board = {
  "5e" => "SHOGI:+P",  # Promoted pawn at origin
  "5f" => nil
}
promoted_result = promoted_engine.where(promoted_board, {}, "SHOGI")
raise unless promoted_result
raise unless promoted_result.diff == { "5e" => nil, "5f" => "SHOGI:+P" }
puts "    ✓ Promoted piece movement works correctly"

# Invalid move (base piece instead of promoted)
base_promoted_board = {
  "5e" => "SHOGI:P",  # Base pawn instead of promoted
  "5f" => nil
}
promoted_result = promoted_engine.where(base_promoted_board, {}, "SHOGI")
raise unless promoted_result.nil?
puts "    ✓ Base piece cannot make promoted piece move"

# Test enemy piece detection
puts "  Testing enemy piece detection..."

enemy_test_data = {
  "CHESS:P" => {
    "e5" => {
      "f6" => [
        {
          "require" => { "f6" => "enemy" },
          "perform" => { "e5" => nil, "f6" => "CHESS:P" },
          "gain" => "CHESS:P"
        }
      ]
    }
  }
}

enemy_piece = Sashite::Ggn::Piece.new(enemy_test_data)
enemy_engine = enemy_piece.select("CHESS:P").from("e5").to("f6")

# Valid capture (enemy piece on target)
capture_board = {
  "e5" => "CHESS:P",
  "f6" => "chess:p"  # Enemy piece (lowercase = opponent)
}
capture_result = enemy_engine.where(capture_board, {}, "CHESS")
raise unless capture_result
raise unless capture_result.gain == "CHESS:P"
puts "    ✓ Enemy piece detection works for captures"

# Invalid capture (friendly piece on target)
friendly_board = {
  "e5" => "CHESS:P",
  "f6" => "CHESS:N"  # Friendly piece (same case)
}
capture_result = enemy_engine.where(friendly_board, {}, "CHESS")
raise unless capture_result.nil?
puts "    ✓ Friendly piece correctly prevents capture"

# Invalid capture (empty square)
empty_board = {
  "e5" => "CHESS:P",
  "f6" => nil  # Empty square
}
capture_result = enemy_engine.where(empty_board, {}, "CHESS")
raise unless capture_result.nil?
puts "    ✓ Empty square correctly prevents capture when enemy required"

puts "\n✅ All tests passed!"
puts "Tested #{Sashite::Ggn::Piece}, #{Sashite::Ggn::Piece::Source}, #{Sashite::Ggn::Piece::Source::Destination}, #{Sashite::Ggn::Piece::Source::Destination::Engine}, and #{Sashite::Ggn::Piece::Source::Destination::Engine::Transition}"
puts "Includes comprehensive tests for pseudo_legal_moves method with performance optimizations"
