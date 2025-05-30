# frozen_string_literal: true

# Tests for Sashite::Ggn::Ruleset conforming to GGN Specification v1.0.0
#
# GGN specifies rule-agnostic, JSON-based format for pseudo-legal moves in abstract strategy board games.
# This test suite validates:
# - Proper initialization and validation of GGN data
# - Detection of logical contradictions in require/prevent conditions
# - Detection of duplicated implicit requirements
# - Correct piece selection and move evaluation
# - Proper handling of complex multi-square moves and promotion variants
# - Error handling for malformed data

require_relative "../../../lib/sashite-ggn"

# Helper function to run a test and report errors
def run_test(name)
  print "  #{name}... "
  yield
  puts "✓ Success"
rescue StandardError => e
  warn "✗ Failure: #{e.message}"
  warn "    #{e.backtrace.first}"
  exit(1)
end

puts
puts "Tests for Sashite::Ggn::Ruleset"
puts

# Valid test data
VALID_SIMPLE_DATA = {
  "CHESS:P" => {
    "e2" => {
      "e4" => [{ "require" => { "e3" => "empty", "e4" => "empty" }, "perform" => { "e2" => nil, "e4" => "CHESS:P" } }],
      "f3" => [{ "require" => { "f3" => "enemy" }, "perform" => { "e2" => nil, "f3" => "CHESS:P" } }]
    }
  },
  "CHESS:K" => {
    "e1" => {
      "e2" => [{ "require" => { "e2" => "empty" }, "perform" => { "e1" => nil, "e2" => "CHESS:K" } }],
      "f1" => [{ "require" => { "f1" => "empty" }, "perform" => { "e1" => nil, "f1" => "CHESS:K" } }]
    }
  }
}.freeze

VALID_COMPLEX_DATA = {
  "CHESS:P" => {
    "e7" => {
      "e8" => [
        { "require" => { "e8" => "empty" }, "perform" => { "e7" => nil, "e8" => "CHESS:Q" } },
        { "require" => { "e8" => "empty" }, "perform" => { "e7" => nil, "e8" => "CHESS:R" } },
        { "require" => { "e8" => "empty" }, "perform" => { "e7" => nil, "e8" => "CHESS:B" } },
        { "require" => { "e8" => "empty" }, "perform" => { "e7" => nil, "e8" => "CHESS:N" } }
      ]
    },
    "d5" => {
      "e6" => [{
        "require" => { "e5" => "chess:p", "e6" => "empty" },
        "perform" => { "d5" => nil, "e5" => nil, "e6" => "CHESS:P" }
      }]
    }
  },
  "CHESS:K" => {
    "e1" => {
      "g1" => [{
        "require" => { "f1" => "empty", "g1" => "empty", "h1" => "CHESS:R" },
        "perform" => { "e1" => nil, "f1" => "CHESS:R", "g1" => "CHESS:K", "h1" => nil }
      }]
    }
  }
}.freeze

# Test data with logical contradictions
CONTRADICTION_DATA = {
  "CHESS:B" => {
    "c1" => {
      "f4" => [{
        "require" => { "d2" => "empty", "e3" => "empty" },
        "prevent" => { "d2" => "empty", "g5" => "CHESS:K" },  # Contradiction: d2 both required and prevented to be empty
        "perform" => { "c1" => nil, "f4" => "CHESS:B" }
      }]
    }
  }
}.freeze

MULTIPLE_CONTRADICTIONS_DATA = {
  "CHESS:Q" => {
    "d1" => {
      "d8" => [{
        "require" => { "d2" => "empty", "d3" => "enemy" },
        "prevent" => { "d2" => "empty", "d3" => "enemy" },  # Multiple contradictions
        "perform" => { "d1" => nil, "d8" => "CHESS:Q" }
      }]
    }
  }
}.freeze

# Test data with implicit requirement duplication
IMPLICIT_REQUIREMENT_DATA = {
  "CHESS:K" => {
    "e1" => {
      "e2" => [{
        "require" => { "e1" => "CHESS:K", "e2" => "empty" },  # e1 => "CHESS:K" is implicit
        "perform" => { "e1" => nil, "e2" => "CHESS:K" }
      }]
    }
  }
}.freeze

MULTIPLE_IMPLICIT_REQUIREMENTS_DATA = {
  "CHESS:P" => {
    "e2" => {
      "e4" => [{
        "require" => { "e2" => "CHESS:P", "e3" => "empty", "e4" => "empty" },  # e2 => "CHESS:P" is implicit
        "perform" => { "e2" => nil, "e4" => "CHESS:P" }
      }]
    }
  },
  "CHESS:K" => {
    "e1" => {
      "f1" => [{
        "require" => { "e1" => "CHESS:K", "f1" => "empty" },  # e1 => "CHESS:K" is implicit
        "perform" => { "e1" => nil, "f1" => "CHESS:K" }
      }]
    }
  }
}.freeze

# Basic initialization tests
run_test("Valid simple data initialization") do
  ruleset = Sashite::Ggn::Ruleset.new(VALID_SIMPLE_DATA)
  raise "Ruleset should be frozen" unless ruleset.frozen?
end

run_test("Valid complex data initialization") do
  ruleset = Sashite::Ggn::Ruleset.new(VALID_COMPLEX_DATA)
  raise "Ruleset should be frozen" unless ruleset.frozen?
end

run_test("Raises ArgumentError for non-Hash input") do
  Sashite::Ggn::Ruleset.new("not a hash")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Expected Hash")
end

run_test("Raises ArgumentError for nil input") do
  Sashite::Ggn::Ruleset.new(nil)
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Expected Hash")
end

run_test("Raises ArgumentError for array input") do
  Sashite::Ggn::Ruleset.new([1, 2, 3])
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Expected Hash")
end

# Logical contradiction detection tests
run_test("Detects logical contradiction in require/prevent") do
  Sashite::Ggn::Ruleset.new(CONTRADICTION_DATA)
  raise "Expected ValidationError for logical contradiction"
rescue Sashite::Ggn::ValidationError => e
  raise "Wrong error type or message: #{e.message}" unless e.message.include?("Logical contradiction detected")
  raise "Error should mention the piece: #{e.message}" unless e.message.include?("CHESS:B")
  raise "Error should mention the squares: #{e.message}" unless e.message.include?("c1") && e.message.include?("f4")
  raise "Error should mention the conflicting square: #{e.message}" unless e.message.include?("d2")
  raise "Error should mention the conflicting state: #{e.message}" unless e.message.include?("empty")
end

run_test("Detects multiple logical contradictions") do
  Sashite::Ggn::Ruleset.new(MULTIPLE_CONTRADICTIONS_DATA)
  raise "Expected ValidationError for multiple contradictions"
rescue Sashite::Ggn::ValidationError => e
  raise "Wrong error type or message: #{e.message}" unless e.message.include?("Logical contradiction detected")
  # Should detect the first contradiction it encounters
  raise "Error should mention a conflicting square: #{e.message}" unless e.message.include?("d2") || e.message.include?("d3")
end

run_test("Allows non-contradictory require/prevent conditions") do
  valid_data = {
    "CHESS:B" => {
      "c1" => {
        "f4" => [{
          "require" => { "d2" => "empty", "e3" => "empty" },
          "prevent" => { "g5" => "CHESS:K", "h6" => "enemy" },  # No contradictions
          "perform" => { "c1" => nil, "f4" => "CHESS:B" }
        }]
      }
    }
  }

  ruleset = Sashite::Ggn::Ruleset.new(valid_data)
  raise "Should accept non-contradictory conditions" unless ruleset.is_a?(Sashite::Ggn::Ruleset)
end

run_test("Allows same square with different states in require/prevent") do
  valid_data = {
    "CHESS:R" => {
      "a1" => {
        "a8" => [{
          "require" => { "a4" => "empty" },
          "prevent" => { "a4" => "enemy" },  # Different states for same square - valid
          "perform" => { "a1" => nil, "a8" => "CHESS:R" }
        }]
      }
    }
  }

  ruleset = Sashite::Ggn::Ruleset.new(valid_data)
  raise "Should accept different states for same square" unless ruleset.is_a?(Sashite::Ggn::Ruleset)
end

# Implicit requirement duplication detection tests
run_test("Detects implicit requirement duplication") do
  Sashite::Ggn::Ruleset.new(IMPLICIT_REQUIREMENT_DATA)
  raise "Expected ValidationError for implicit requirement duplication"
rescue Sashite::Ggn::ValidationError => e
  raise "Wrong error type or message: #{e.message}" unless e.message.include?("Implicit requirement duplication detected")
  raise "Error should mention the piece: #{e.message}" unless e.message.include?("CHESS:K")
  raise "Error should mention the squares: #{e.message}" unless e.message.include?("e1") && e.message.include?("e2")
  raise "Error should explain the redundancy: #{e.message}" unless e.message.include?("already implicit")
end

run_test("Detects multiple implicit requirement duplications") do
  Sashite::Ggn::Ruleset.new(MULTIPLE_IMPLICIT_REQUIREMENTS_DATA)
  raise "Expected ValidationError for implicit requirement duplication"
rescue Sashite::Ggn::ValidationError => e
  raise "Wrong error type or message: #{e.message}" unless e.message.include?("Implicit requirement duplication detected")
  # Should detect one of the duplications
  raise "Error should mention a piece: #{e.message}" unless e.message.include?("CHESS:P") || e.message.include?("CHESS:K")
end

run_test("Allows non-implicit requirements") do
  valid_data = {
    "CHESS:K" => {
      "e1" => {
        "e2" => [{
          "require" => { "e2" => "empty", "f1" => "empty" },  # Only non-implicit requirements
          "perform" => { "e1" => nil, "e2" => "CHESS:K" }
        }]
      }
    }
  }

  ruleset = Sashite::Ggn::Ruleset.new(valid_data)
  raise "Should accept non-implicit requirements" unless ruleset.is_a?(Sashite::Ggn::Ruleset)
end

run_test("Allows empty require field") do
  valid_data = {
    "CHESS:K" => {
      "e1" => {
        "e2" => [{
          "perform" => { "e1" => nil, "e2" => "CHESS:K" }  # No require field at all
        }]
      }
    }
  }

  ruleset = Sashite::Ggn::Ruleset.new(valid_data)
  raise "Should accept missing require field" unless ruleset.is_a?(Sashite::Ggn::Ruleset)
end

# Piece selection tests
run_test("Selects existing piece successfully") do
  ruleset = Sashite::Ggn::Ruleset.new(VALID_SIMPLE_DATA)
  source = ruleset.select("CHESS:P")
  raise "Should return Source instance" unless source.is_a?(Sashite::Ggn::Ruleset::Source)
end

run_test("Raises KeyError for non-existent piece") do
  ruleset = Sashite::Ggn::Ruleset.new(VALID_SIMPLE_DATA)
  ruleset.select("NONEXISTENT:X")
  raise "Expected KeyError"
rescue KeyError
  # Expected
end

run_test("Case-sensitive piece selection") do
  ruleset = Sashite::Ggn::Ruleset.new(VALID_SIMPLE_DATA)

  # Should work for exact match
  source = ruleset.select("CHESS:P")
  raise "Should find uppercase piece" unless source.is_a?(Sashite::Ggn::Ruleset::Source)

  # Should fail for different case
  begin
    ruleset.select("chess:p")
    raise "Should not find lowercase piece in uppercase data"
  rescue KeyError
    # Expected
  end
end

# Pseudo-legal transitions tests
run_test("Returns empty array for empty board") do
  ruleset = Sashite::Ggn::Ruleset.new(VALID_SIMPLE_DATA)
  moves = ruleset.pseudo_legal_transitions({}, "CHESS")
  raise "Should return empty array for empty board" unless moves == []
end

run_test("Returns moves for pieces on board") do
  ruleset = Sashite::Ggn::Ruleset.new(VALID_SIMPLE_DATA)
  board = { "e2" => "CHESS:P", "e3" => nil, "e4" => nil }
  moves = ruleset.pseudo_legal_transitions(board, "CHESS")
  raise "Should return array of moves" unless moves.is_a?(Array)
  raise "Should find at least one move" if moves.empty?

  # Check structure of returned moves
  actor, origin, target, transitions = moves.first
  raise "Actor should be string" unless actor.is_a?(String)
  raise "Origin should be string" unless origin.is_a?(String)
  raise "Target should be string" unless target.is_a?(String)
  raise "Transitions should be array" unless transitions.is_a?(Array)
end

run_test("Filters by player ownership") do
  ruleset = Sashite::Ggn::Ruleset.new(VALID_SIMPLE_DATA)
  board = { "e2" => "CHESS:P", "e3" => nil, "e4" => nil }

  # Should find moves for uppercase player
  moves_white = ruleset.pseudo_legal_transitions(board, "CHESS")
  raise "Should find moves for uppercase player" if moves_white.empty?

  # Should not find moves for lowercase player
  moves_black = ruleset.pseudo_legal_transitions(board, "chess")
  raise "Should not find moves for different player" unless moves_black.empty?
end

run_test("Handles promotion variants") do
  ruleset = Sashite::Ggn::Ruleset.new(VALID_COMPLEX_DATA)
  board = { "e7" => "CHESS:P", "e8" => nil }
  moves = ruleset.pseudo_legal_transitions(board, "CHESS")

  # Find promotion move
  promotion_move = moves.find { |actor, origin, target, _| actor == "CHESS:P" && origin == "e7" && target == "e8" }
  raise "Should find promotion move" unless promotion_move

  _, _, _, transitions = promotion_move
  raise "Should have multiple promotion variants" unless transitions.size > 1
  raise "Should have 4 promotion choices" unless transitions.size == 4

  # Check that different pieces result from promotion
  promoted_pieces = transitions.map { |t| t.diff["e8"] }.uniq
  raise "Should have different promotion pieces" unless promoted_pieces.size == 4
end

run_test("Handles complex multi-square moves") do
  ruleset = Sashite::Ggn::Ruleset.new(VALID_COMPLEX_DATA)
  board = { "e1" => "CHESS:K", "f1" => nil, "g1" => nil, "h1" => "CHESS:R" }
  moves = ruleset.pseudo_legal_transitions(board, "CHESS")

  # Find castling move
  castling_move = moves.find { |actor, origin, target, _| actor == "CHESS:K" && origin == "e1" && target == "g1" }
  raise "Should find castling move" unless castling_move

  _, _, _, transitions = castling_move
  raise "Should have one castling variant" unless transitions.size == 1

  transition = transitions.first
  expected_changes = { "e1" => nil, "f1" => "CHESS:R", "g1" => "CHESS:K", "h1" => nil }
  raise "Should perform correct castling transformation" unless transition.diff == expected_changes
end

run_test("Handles en passant capture") do
  ruleset = Sashite::Ggn::Ruleset.new(VALID_COMPLEX_DATA)
  board = { "d5" => "CHESS:P", "e5" => "chess:p", "e6" => nil }
  moves = ruleset.pseudo_legal_transitions(board, "CHESS")

  # Find en passant move
  en_passant_move = moves.find { |actor, origin, target, _| actor == "CHESS:P" && origin == "d5" && target == "e6" }
  raise "Should find en passant move" unless en_passant_move

  _, _, _, transitions = en_passant_move
  raise "Should have one en passant variant" unless transitions.size == 1

  transition = transitions.first
  expected_changes = { "d5" => nil, "e5" => nil, "e6" => "CHESS:P" }
  raise "Should perform correct en passant transformation" unless transition.diff == expected_changes
end

# Parameter validation tests
run_test("Validates board_state parameter type") do
  ruleset = Sashite::Ggn::Ruleset.new(VALID_SIMPLE_DATA)
  ruleset.pseudo_legal_transitions("not a hash", "CHESS")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("board_state must be a Hash")
end

run_test("Validates active_game parameter type") do
  ruleset = Sashite::Ggn::Ruleset.new(VALID_SIMPLE_DATA)
  ruleset.pseudo_legal_transitions({}, 123)
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("active_game must be a String")
end

run_test("Validates active_game parameter content") do
  ruleset = Sashite::Ggn::Ruleset.new(VALID_SIMPLE_DATA)
  ruleset.pseudo_legal_transitions({}, "")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("active_game cannot be empty")
end

run_test("Validates active_game format") do
  ruleset = Sashite::Ggn::Ruleset.new(VALID_SIMPLE_DATA)
  ruleset.pseudo_legal_transitions({}, "Chess123")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid active_game format")
end

# Edge cases
run_test("Handles empty GGN data") do
  ruleset = Sashite::Ggn::Ruleset.new({})
  moves = ruleset.pseudo_legal_transitions({ "e1" => "CHESS:K" }, "CHESS")
  raise "Should return empty array for empty GGN data" unless moves == []
end

run_test("Handles mixed case game identifiers correctly") do
  mixed_data = {
    "CHESS:P" => {
      "e2" => {
        "e4" => [{ "perform" => { "e2" => nil, "e4" => "CHESS:P" } }]
      }
    },
    "chess:p" => {
      "e7" => {
        "e5" => [{ "perform" => { "e7" => nil, "e5" => "chess:p" } }]
      }
    }
  }

  ruleset = Sashite::Ggn::Ruleset.new(mixed_data)

  # Test uppercase player
  board_white = { "e2" => "CHESS:P" }
  moves_white = ruleset.pseudo_legal_transitions(board_white, "CHESS")
  raise "Should find uppercase piece for uppercase player" if moves_white.empty?

  # Test lowercase player
  board_black = { "e7" => "chess:p" }
  moves_black = ruleset.pseudo_legal_transitions(board_black, "chess")
  raise "Should find lowercase piece for lowercase player" if moves_black.empty?

  # Cross-ownership should not work
  moves_cross = ruleset.pseudo_legal_transitions(board_white, "chess")
  raise "Should not find uppercase piece for lowercase player" unless moves_cross.empty?
end

run_test("Handles malformed transition data gracefully") do
  # Test with missing perform field (should be caught by schema validation)
  malformed_data = {
    "CHESS:P" => {
      "e2" => {
        "e4" => [{ "require" => { "e4" => "empty" } }]  # Missing perform
      }
    }
  }

  # This should work during initialization since we're not validating schema here
  # But the move evaluation should handle missing perform gracefully
  ruleset = Sashite::Ggn::Ruleset.new(malformed_data)
  board = { "e2" => "CHESS:P", "e4" => nil }
  moves = ruleset.pseudo_legal_transitions(board, "CHESS")
  # Should not crash, might return empty results
  raise "Should not crash on malformed data" unless moves.is_a?(Array)
end

puts
puts "All tests passed! ✓"
puts "Tested: Initialization, Logical contradictions, Implicit requirements, Piece selection, Move evaluation"
puts "Coverage: Validation, Error handling, Edge cases, Complex moves, Player ownership"
