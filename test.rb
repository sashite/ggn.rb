#!/usr/bin/env ruby
# frozen_string_literal: true

require "simplecov"

SimpleCov.command_name "Unit Tests"
SimpleCov.start

# Tests for Sashite::Ggn (General Gameplay Notation)
#
# Tests the GGN implementation for Ruby, covering validation,
# parsing, movement possibility evaluation, and condition checking
# according to the GGN Specification v1.0.0.
#
# @see https://sashite.dev/specs/ggn/1.0.0/ GGN Specification v1.0.0

require_relative "lib/sashite-ggn"

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
puts "Tests for Sashite::Ggn (General Gameplay Notation) v1.0.0"
puts "Validating compliance with GGN Specification v1.0.0"
puts "Specification: https://sashite.dev/specs/ggn/1.0.0/"
puts

# ============================================================================
# MODULE-LEVEL VALIDATION TESTS
# ============================================================================

run_test("Module validation accepts valid GGN structures") do
  valid_ggn = {
    "C:P" => {
      "e2" => {
        "e4" => [
          {
            "must" => { "e3" => "empty", "e4" => "empty" },
            "deny" => {},
            "diff" => {
              "board" => { "e2" => nil, "e4" => "C:P" },
              "toggle" => true
            }
          }
        ]
      }
    }
  }

  raise "Valid GGN should be accepted" unless Sashite::Ggn.valid?(valid_ggn)
end

run_test("Module validation rejects invalid structures") do
  invalid_cases = [
    nil,
    [],
    "",
    { "1nvalid:qpi" => {} },
    { "C:K" => "not a hash" },
    { "C:K" => { "invalid_cell" => {} } },
    { "C:K" => { "e1" => "not a hash" } },
    { "C:K" => { "e1" => { "e2" => "not an array" } } },
    { "C:K" => { "e1" => { "e2" => [{ "must" => "1nvalid" }] } } }
  ]

  invalid_cases.each do |invalid_ggn|
    raise "#{invalid_ggn.inspect} should be invalid" if Sashite::Ggn.valid?(invalid_ggn)
  end
end

# ============================================================================
# MODULE-LEVEL PARSING TESTS
# ============================================================================

run_test("Module parse creates Ruleset instances") do
  ggn_data = {
    "C:K" => {
      "e1" => {
        "e2" => [
          {
            "must" => { "e2" => "empty" },
            "deny" => {},
            "diff" => {
              "board" => { "e1" => nil, "e2" => "C:K" },
              "toggle" => true
            }
          }
        ]
      }
    }
  }

  ruleset = Sashite::Ggn.parse(ggn_data)

  raise "parse should return Ruleset instance" unless ruleset.is_a?(Sashite::Ggn::Ruleset)
  raise "ruleset should have correct pieces" unless ruleset.pieces.include?("C:K")
end

run_test("Module parse raises errors for invalid data") do
  begin
    Sashite::Ggn.parse({ "invalid:qpi" => {} })
    raise "Should have raised error for invalid QPI"
  rescue ArgumentError
    # Expected
  end

  begin
    Sashite::Ggn.parse({ "C:K" => { "invalid_cell" => {} } })
    raise "Should have raised error for invalid CELL"
  rescue ArgumentError
    # Expected
  end
end

# ============================================================================
# RULESET CLASS TESTS
# ============================================================================

run_test("Ruleset initialization without validation") do
  valid_data = {
    "C:P" => {
      "e2" => {
        "e4" => [
          {
            "must" => { "e3" => "empty", "e4" => "empty" },
            "deny" => {},
            "diff" => {
              "board" => { "e2" => nil, "e4" => "C:P" },
              "toggle" => true
            }
          }
        ]
      }
    }
  }

  ruleset = Sashite::Ggn::Ruleset.new(valid_data)
  raise "Ruleset should be created successfully" unless ruleset.is_a?(Sashite::Ggn::Ruleset)
end

run_test("Ruleset select method returns Source") do
  ggn_data = {
    "C:K" => {
      "e1" => {
        "e2" => [
          {
            "must" => { "e2" => "empty" },
            "deny" => {},
            "diff" => {
              "board" => { "e1" => nil, "e2" => "C:K" },
              "toggle" => true
            }
          }
        ]
      }
    }
  }

  ruleset = Sashite::Ggn::Ruleset.new(ggn_data)
  source = ruleset.select("C:K")

  raise "select should return Source" unless source.is_a?(Sashite::Ggn::Ruleset::Source)
end

run_test("Ruleset select raises KeyError for non-existent piece") do
  ruleset = Sashite::Ggn::Ruleset.new({})

  begin
    ruleset.select("C:Z")
    raise "Should have raised KeyError"
  rescue KeyError => e
    raise "Error should mention piece" unless e.message.include?("C:Z")
  end
end

run_test("Ruleset piece? method") do
  ggn_data = {
    "C:K" => {
      "e1" => {
        "e2" => [
          {
            "must" => {},
            "deny" => {},
            "diff" => { "board" => { "e1" => nil, "e2" => "C:K" }, "toggle" => true }
          }
        ]
      }
    }
  }

  ruleset = Sashite::Ggn::Ruleset.new(ggn_data)

  raise "piece? should return true for existing piece" unless ruleset.piece?("C:K")
  raise "piece? should return false for non-existing piece" if ruleset.piece?("C:Q")
end

run_test("Ruleset pieces method") do
  ggn_data = {
    "C:K" => { "e1" => { "e2" => [{ "must" => {}, "deny" => {}, "diff" => { "toggle" => true } }] } },
    "C:Q" => { "d1" => { "d4" => [{ "must" => {}, "deny" => {}, "diff" => { "toggle" => true } }] } },
    "C:R" => { "a1" => { "a4" => [{ "must" => {}, "deny" => {}, "diff" => { "toggle" => true } }] } }
  }

  ruleset = Sashite::Ggn::Ruleset.new(ggn_data)
  pieces = ruleset.pieces

  raise "pieces should return array" unless pieces.is_a?(Array)
  raise "pieces should have 3 elements" unless pieces.size == 3
  raise "pieces should include C:K" unless pieces.include?("C:K")
  raise "pieces should include C:Q" unless pieces.include?("C:Q")
  raise "pieces should include C:R" unless pieces.include?("C:R")
end

# ============================================================================
# SOURCE CLASS TESTS
# ============================================================================

run_test("Source from method returns Destination") do
  source_data = {
    "e1" => {
      "e2" => [
        { "must" => {}, "deny" => {}, "diff" => { "toggle" => true } }
      ]
    }
  }

  source = Sashite::Ggn::Ruleset::Source.new(source_data)
  destination = source.from("e1")

  raise "from should return Destination" unless destination.is_a?(Sashite::Ggn::Ruleset::Source::Destination)
end

run_test("Source from raises KeyError for non-existent source") do
  source = Sashite::Ggn::Ruleset::Source.new({})

  begin
    source.from("z9")
    raise "Should have raised KeyError"
  rescue KeyError => e
    raise "Error should mention source" unless e.message.include?("z9")
  end
end

run_test("Source sources method") do
  source_data = {
    "e1" => { "e2" => [] },
    "d1" => { "d4" => [] },
    "*" => { "e4" => [] }
  }

  source = Sashite::Ggn::Ruleset::Source.new(source_data)
  sources = source.sources

  raise "sources should return array" unless sources.is_a?(Array)
  raise "sources should have 3 elements" unless sources.size == 3
  raise "sources should include e1" unless sources.include?("e1")
  raise "sources should include d1" unless sources.include?("d1")
  raise "sources should include *" unless sources.include?("*")
end

run_test("Source source? method") do
  source_data = {
    "e1" => { "e2" => [] },
    "*" => { "e4" => [] }
  }

  source = Sashite::Ggn::Ruleset::Source.new(source_data)

  raise "source? should return true for existing source" unless source.source?("e1")
  raise "source? should return true for HAND" unless source.source?("*")
  raise "source? should return false for non-existing source" if source.source?("z9")
end

# ============================================================================
# DESTINATION CLASS TESTS
# ============================================================================

run_test("Destination to method returns Engine") do
  destination_data = {
    "e2" => [
      { "must" => {}, "deny" => {}, "diff" => { "toggle" => true } }
    ]
  }

  destination = Sashite::Ggn::Ruleset::Source::Destination.new(destination_data)
  engine = destination.to("e2")

  raise "to should return Engine" unless engine.is_a?(Sashite::Ggn::Ruleset::Source::Destination::Engine)
end

run_test("Destination to raises KeyError for non-existent destination") do
  destination = Sashite::Ggn::Ruleset::Source::Destination.new({})

  begin
    destination.to("z9")
    raise "Should have raised KeyError"
  rescue KeyError => e
    raise "Error should mention destination" unless e.message.include?("z9")
  end
end

run_test("Destination destinations method") do
  destination_data = {
    "e2" => [],
    "f2" => [],
    "d2" => []
  }

  destination = Sashite::Ggn::Ruleset::Source::Destination.new(destination_data)
  destinations = destination.destinations

  raise "destinations should return array" unless destinations.is_a?(Array)
  raise "destinations should have 3 elements" unless destinations.size == 3
  raise "destinations should include e2" unless destinations.include?("e2")
  raise "destinations should include f2" unless destinations.include?("f2")
  raise "destinations should include d2" unless destinations.include?("d2")
end

run_test("Destination destination? method") do
  destination_data = {
    "e2" => [],
    "*" => []
  }

  destination = Sashite::Ggn::Ruleset::Source::Destination.new(destination_data)

  raise "destination? should return true for existing destination" unless destination.destination?("e2")
  raise "destination? should return true for HAND" unless destination.destination?("*")
  raise "destination? should return false for non-existing destination" if destination.destination?("z9")
end

# ============================================================================
# ENGINE CLASS TESTS
# ============================================================================

run_test("Engine where method evaluates conditions") do
  possibilities = [
    {
      "must" => { "e2" => "empty" },
      "deny" => {},
      "diff" => {
        "board" => { "e1" => nil, "e2" => "M:K" },
        "toggle" => true
      }
    }
  ]

  engine = Sashite::Ggn::Ruleset::Source::Destination::Engine.new(*possibilities)

  active_side = :first
  squares = {
    "e1" => "M:K",
    "e2" => nil
  }

  transitions = engine.where(active_side, squares)

  raise "where should return array" unless transitions.is_a?(Array)
  raise "where should return transitions for matching conditions" unless transitions.size == 1
  raise "transition should be STN Transition" unless transitions.first.is_a?(Sashite::Stn::Transition)
  raise "transition should have correct board changes" unless transitions.first.to_h == { board: { "e1" => nil, "e2" => "M:K" }, toggle: true }
end

run_test("Engine where returns empty array when conditions not met") do
  possibilities = [
    {
      "must" => { "e4" => "enemy" },
      "deny" => {},
      "diff" => { "toggle" => true }
    }
  ]

  engine = Sashite::Ggn::Ruleset::Source::Destination::Engine.new(*possibilities)

  active_side = :first
  squares = {
    "e2" => "C:P",
    "e4" => nil  # Empty, not enemy
  }

  transitions = engine.where(active_side, squares)

  raise "where should return empty array when conditions not met" unless transitions.empty?
end

run_test("Engine evaluates 'empty' keyword correctly") do
  possibilities = [
    {
      "must" => { "e3" => "empty", "e4" => "empty" },
      "deny" => {},
      "diff" => {
        "board" => { "e2" => nil, "e4" => "C:P" },
        "toggle" => true
      }
    }
  ]

  engine = Sashite::Ggn::Ruleset::Source::Destination::Engine.new(*possibilities)

  active_side = :first
  squares = {
    "e2" => "C:P",
    "e3" => nil,
    "e4" => nil
  }

  transitions = engine.where(active_side, squares)

  raise "empty keyword should be evaluated correctly" unless transitions.size == 1
end

run_test("Engine evaluates 'enemy' keyword correctly") do
  possibilities = [
    {
      "must" => { "e4" => "enemy" },
      "deny" => {},
      "diff" => {
        "board" => { "e3" => nil, "e4" => "C:P" },
        "toggle" => true
      }
    }
  ]

  engine = Sashite::Ggn::Ruleset::Source::Destination::Engine.new(*possibilities)

  active_side = :first
  squares = {
    "e3" => "C:P",
    "e4" => "c:p"  # Enemy piece
  }

  transitions = engine.where(active_side, squares)

  raise "enemy keyword should be evaluated correctly" unless transitions.size == 1
end

run_test("Engine evaluates QPI identifier conditions correctly") do
  possibilities = [
    {
      "must" => { "h1" => "C:+R", "e1" => "C:+K" },
      "deny" => {},
      "diff" => { "toggle" => true }
    }
  ]

  engine = Sashite::Ggn::Ruleset::Source::Destination::Engine.new(*possibilities)

  active_side = :first
  squares = {
    "e1" => "C:+K",
    "h1" => "C:+R"
  }

  transitions = engine.where(active_side, squares)

  raise "QPI identifier conditions should be evaluated" unless transitions.is_a?(Array)
  raise "QPI identifier conditions should match" unless transitions.size == 1
end

run_test("Engine evaluates 'deny' conditions correctly") do
  possibilities = [
    {
      "must" => {},
      "deny" => { "e3" => "enemy" },
      "diff" => {
        "board" => { "e2" => nil, "e4" => "C:P" },
        "toggle" => true
      }
    }
  ]

  engine = Sashite::Ggn::Ruleset::Source::Destination::Engine.new(*possibilities)

  active_side = :first

  # Board with enemy at e3 - should fail deny
  squares_denied = {
    "e2" => "C:P",
    "e3" => "c:p",  # Enemy piece
    "e4" => nil
  }
  transitions_denied = engine.where(active_side, squares_denied)

  # Board without enemy at e3 - should pass
  squares_allowed = {
    "e2" => "C:P",
    "e3" => nil,
    "e4" => nil
  }
  transitions_allowed = engine.where(active_side, squares_allowed)

  raise "deny should reject when condition met" unless transitions_denied.empty?
  raise "deny should allow when condition not met" unless transitions_allowed.size == 1
end

# ============================================================================
# METHOD CHAINING TESTS
# ============================================================================

run_test("Method chaining works correctly") do
  ggn_data = {
    "C:K" => {
      "e1" => {
        "e2" => [
          {
            "must" => { "e2" => "empty" },
            "deny" => {},
            "diff" => {
              "board" => { "e1" => nil, "e2" => "C:K" },
              "toggle" => true
            }
          }
        ]
      }
    }
  }

  ruleset = Sashite::Ggn::Ruleset.new(ggn_data)

  active_side = :first
  squares = {
    "e1" => "C:K",
    "e2" => nil
  }

  transitions = ruleset
    .select("C:K")
    .from("e1")
    .to("e2")
    .where(active_side, squares)

  raise "method chaining should work" unless transitions.is_a?(Array)
  raise "transitions should contain results" unless transitions.size == 1
end

# ============================================================================
# HAND (DROP) NOTATION TESTS
# ============================================================================

run_test("Engine handles HAND notation for drops") do
  possibilities = [
    {
      "must" => { "e4" => "empty" },
      "deny" => {},
      "diff" => {
        "board" => { "e4" => "S:P" },
        "hands" => { "S:P" => -1 },
        "toggle" => true
      }
    }
  ]

  engine = Sashite::Ggn::Ruleset::Source::Destination::Engine.new(*possibilities)

  active_side = :first
  squares = {
    "e4" => nil  # Empty square for drop
  }

  transitions = engine.where(active_side, squares)

  raise "HAND notation should work for drops" unless transitions.is_a?(Array)
  raise "Drop should be allowed when square is empty" unless transitions.size == 1
end

# ============================================================================
# VALIDATION ERROR TESTS
# ============================================================================

run_test("Validation catches invalid QPI in piece key") do
  begin
    Sashite::Ggn.parse({ "1nvalid" => {} })
    raise "Should have raised error for invalid QPI"
  rescue ArgumentError => e
    raise "Error should mention QPI" unless e.message.include?("QPI")
  end
end

run_test("Validation catches invalid CELL in source") do
  begin
    Sashite::Ggn.parse({
      "C:K" => {
        "invalid_cell" => {}
      }
    })
    raise "Should have raised error for invalid CELL"
  rescue ArgumentError => e
    raise "Error should mention location" unless e.message.downcase.include?("location")
  end
end

run_test("Validation catches invalid LCN in must field") do
  begin
    Sashite::Ggn.parse({
      "C:K" => {
        "e1" => {
          "e2" => [
            {
              "must" => { "1nvalid" => "empty" },
              "deny" => {},
              "diff" => {}
            }
          ]
        }
      }
    })
    raise "Should have raised error for invalid LCN"
  rescue ArgumentError
    # Expected
  end
end

run_test("Validation catches invalid STN in diff field") do
  begin
    Sashite::Ggn.parse({
      "C:K" => {
        "e1" => {
          "e2" => [
            {
              "must" => {},
              "deny" => {},
              "diff" => { "board" => { "1nvalid" => "C:K" } }
            }
          ]
        }
      }
    })
    raise "Should have raised error for invalid STN"
  rescue ArgumentError
    # Expected
  end
end

# ============================================================================
# COMPLEX SCENARIOS
# ============================================================================

run_test("Complex castling scenario") do
  ggn_data = {
    "C:K" => {
      "e1" => {
        "g1" => [
          {
            "must" => { "f1" => "empty", "g1" => "empty", "h1" => "C:+R" },
            "deny" => {},
            "diff" => {
              "board" => {
                "e1" => nil,
                "g1" => "C:K",
                "h1" => nil,
                "f1" => "C:R"
              },
              "toggle" => true
            }
          }
        ]
      }
    }
  }

  ruleset = Sashite::Ggn::Ruleset.new(ggn_data)

  active_side = :first
  squares = {
    "e1" => "C:+K",
    "f1" => nil,
    "g1" => nil,
    "h1" => "C:+R"
  }

  transitions = ruleset
    .select("C:K")
    .from("e1")
    .to("g1")
    .where(active_side, squares)

  raise "Castling scenario should work" unless transitions.is_a?(Array)
  raise "Castling should be allowed" unless transitions.size == 1
end

run_test("En passant capture scenario") do
  ggn_data = {
    "C:P" => {
      "e5" => {
        "f6" => [
          {
            "must" => { "f6" => "empty", "f5" => "c:-p" },
            "deny" => {},
            "diff" => {
              "board" => {
                "e5" => nil,
                "f5" => nil,
                "f6" => "C:P"
              },
              "toggle" => true
            }
          }
        ]
      }
    }
  }

  ruleset = Sashite::Ggn::Ruleset.new(ggn_data)

  active_side = :first
  squares = {
    "e5" => "C:P",
    "f5" => "c:-p",  # Vulnerable enemy pawn
    "f6" => nil
  }

  transitions = ruleset
    .select("C:P")
    .from("e5")
    .to("f6")
    .where(active_side, squares)

  raise "En passant scenario should work" unless transitions.is_a?(Array)
  raise "En passant should be allowed" unless transitions.size == 1
end

run_test("Shogi pawn drop restriction") do
  ggn_data = {
    "S:P" => {
      "*" => {
        "e4" => [
          {
            "must" => { "e4" => "empty" },
            "deny" => {
              "e1" => "S:P", "e2" => "S:P", "e3" => "S:P",
              "e5" => "S:P", "e6" => "S:P", "e7" => "S:P",
              "e8" => "S:P", "e9" => "S:P"
            },
            "diff" => {
              "board" => { "e4" => "S:P" },
              "hands" => { "S:P" => -1 },
              "toggle" => true
            }
          }
        ]
      }
    }
  }

  ruleset = Sashite::Ggn::Ruleset.new(ggn_data)

  active_side = :first

  # Position with pawn already on file e
  squares_blocked = {
    "e1" => nil, "e2" => nil, "e3" => nil,
    "e4" => nil,
    "e5" => "S:P",  # Pawn already on this file
    "e6" => nil, "e7" => nil, "e8" => nil, "e9" => nil
  }
  transitions_blocked = ruleset.select("S:P").from("*").to("e4").where(active_side, squares_blocked)

  # Position without pawn on file e
  squares_allowed = {
    "e1" => nil, "e2" => nil, "e3" => nil,
    "e4" => nil,
    "e5" => nil, "e6" => nil, "e7" => nil, "e8" => nil, "e9" => nil
  }
  transitions_allowed = ruleset.select("S:P").from("*").to("e4").where(active_side, squares_allowed)

  raise "Pawn drop should be blocked when file has pawn" unless transitions_blocked.empty?
  raise "Pawn drop should be allowed when file is clear" unless transitions_allowed.size == 1
end

# ============================================================================
# SPECIFICATION COMPLIANCE
# ============================================================================

run_test("GGN structure matches specification") do
  # Verify structure: piece -> source -> destination -> possibilities array
  ggn_data = {
    "C:P" => {
      "e2" => {
        "e4" => [
          {
            "must" => { "e3" => "empty", "e4" => "empty" },
            "deny" => {},
            "diff" => {
              "board" => { "e2" => nil, "e4" => "C:P" },
              "toggle" => true
            }
          }
        ]
      }
    }
  }

  ruleset = Sashite::Ggn::Ruleset.new(ggn_data)

  raise "Structure should match specification" unless ruleset.piece?("C:P")

  source = ruleset.select("C:P")
  raise "Source level should exist" unless source.source?("e2")

  destination = source.from("e2")
  raise "Destination level should exist" unless destination.destination?("e4")

  engine = destination.to("e4")
  raise "Engine should be created" unless engine.is_a?(Sashite::Ggn::Ruleset::Source::Destination::Engine)
end

puts
puts "All GGN tests passed!"
puts
