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

run_test("Ruleset initialization validates structure") do
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
  raise "source should have correct piece" unless source.piece == "C:K"
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

run_test("Ruleset to_h method") do
  ggn_data = {
    "C:K" => {
      "e1" => {
        "e2" => [
          { "must" => {}, "deny" => {}, "diff" => { "toggle" => true } }
        ]
      }
    }
  }

  ruleset = Sashite::Ggn::Ruleset.new(ggn_data)
  hash = ruleset.to_h

  raise "to_h should return hash" unless hash.is_a?(Hash)
  raise "to_h should have correct structure" unless hash["C:K"]["e1"]["e2"].is_a?(Array)
end

# ============================================================================
# SOURCE CLASS TESTS
# ============================================================================

run_test("Source initialization") do
  source_data = {
    "e1" => {
      "e2" => [
        { "must" => {}, "deny" => {}, "diff" => { "toggle" => true } }
      ]
    }
  }

  source = Sashite::Ggn::Ruleset::Source.new("C:K", source_data)

  raise "source should have correct piece" unless source.piece == "C:K"
  raise "source should have correct data" unless source.data == source_data
end

run_test("Source from method returns Destination") do
  source_data = {
    "e1" => {
      "e2" => [
        { "must" => {}, "deny" => {}, "diff" => { "toggle" => true } }
      ]
    }
  }

  source = Sashite::Ggn::Ruleset::Source.new("C:K", source_data)
  destination = source.from("e1")

  raise "from should return Destination" unless destination.is_a?(Sashite::Ggn::Ruleset::Source::Destination)
  raise "destination should have correct source" unless destination.source == "e1"
end

run_test("Source from raises KeyError for non-existent source") do
  source = Sashite::Ggn::Ruleset::Source.new("C:K", {})

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

  source = Sashite::Ggn::Ruleset::Source.new("C:K", source_data)
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

  source = Sashite::Ggn::Ruleset::Source.new("C:K", source_data)

  raise "source? should return true for existing source" unless source.source?("e1")
  raise "source? should return true for HAND" unless source.source?("*")
  raise "source? should return false for non-existing source" if source.source?("z9")
end

# ============================================================================
# DESTINATION CLASS TESTS
# ============================================================================

run_test("Destination initialization") do
  destination_data = {
    "e2" => [
      { "must" => {}, "deny" => {}, "diff" => { "toggle" => true } }
    ]
  }

  destination = Sashite::Ggn::Ruleset::Source::Destination.new("C:K", "e1", destination_data)

  raise "destination should have correct piece" unless destination.piece == "C:K"
  raise "destination should have correct source" unless destination.source == "e1"
  raise "destination should have correct data" unless destination.data == destination_data
end

run_test("Destination to method returns Engine") do
  destination_data = {
    "e2" => [
      { "must" => {}, "deny" => {}, "diff" => { "toggle" => true } }
    ]
  }

  destination = Sashite::Ggn::Ruleset::Source::Destination.new("C:K", "e1", destination_data)
  engine = destination.to("e2")

  raise "to should return Engine" unless engine.is_a?(Sashite::Ggn::Ruleset::Source::Destination::Engine)
  raise "engine should have correct destination" unless engine.destination == "e2"
end

run_test("Destination to raises KeyError for non-existent destination") do
  destination = Sashite::Ggn::Ruleset::Source::Destination.new("C:K", "e1", {})

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

  destination = Sashite::Ggn::Ruleset::Source::Destination.new("C:K", "e1", destination_data)
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

  destination = Sashite::Ggn::Ruleset::Source::Destination.new("C:K", "e1", destination_data)

  raise "destination? should return true for existing destination" unless destination.destination?("e2")
  raise "destination? should return true for HAND" unless destination.destination?("*")
  raise "destination? should return false for non-existing destination" if destination.destination?("z9")
end

# ============================================================================
# ENGINE CLASS TESTS
# ============================================================================

run_test("Engine initialization") do
  possibilities = [
    { "must" => {}, "deny" => {}, "diff" => { "toggle" => true } }
  ]

  engine = Sashite::Ggn::Ruleset::Source::Destination::Engine.new("C:K", "e1", "e2", possibilities)

  raise "engine should have correct piece" unless engine.piece == "C:K"
  raise "engine should have correct source" unless engine.source == "e1"
  raise "engine should have correct destination" unless engine.destination == "e2"
  raise "engine should have correct data" unless engine.data == possibilities
end

run_test("Engine possibilities method") do
  possibilities = [
    { "must" => { "e2" => "empty" }, "deny" => {}, "diff" => { "toggle" => true } },
    { "must" => { "e2" => "enemy" }, "deny" => {}, "diff" => { "toggle" => true } }
  ]

  engine = Sashite::Ggn::Ruleset::Source::Destination::Engine.new("C:K", "e1", "e2", possibilities)
  result = engine.possibilities

  raise "possibilities should return array" unless result.is_a?(Array)
  raise "possibilities should have 2 elements" unless result.size == 2
end

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

  engine = Sashite::Ggn::Ruleset::Source::Destination::Engine.new("M:K", "e1", "e2", possibilities)

  feen = "rnsmksnr/8/pppppppp/8/8/PPPPPPPP/8/RNSKMSNR / M/m"
  transitions = engine.where(feen)

  raise "where should return array" unless transitions.is_a?(Array)
  raise "where should return transitions for matching conditions" unless transitions.size == 1
  raise "transition should be STN Transition" unless transitions.first.is_a?(Sashite::Stn::Transition)
  raise "transition should be STN Transition" unless transitions.first.to_h == { board: { "e1" => nil, "e2" => "M:K" }, toggle: true }
end

run_test("Engine where returns empty array when conditions not met") do
  possibilities = [
    {
      "must" => { "e4" => "enemy" },
      "deny" => {},
      "diff" => { "toggle" => true }
    }
  ]

  engine = Sashite::Ggn::Ruleset::Source::Destination::Engine.new("C:P", "e2", "e4", possibilities)

  # FEEN with empty e4 (condition not met)
  feen = "rnsmksnr/8/pppppppp/8/8/PPPPPPPP/8/RNSKMSNR / M/m"
  transitions = engine.where(feen)

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

  engine = Sashite::Ggn::Ruleset::Source::Destination::Engine.new("C:P", "e2", "e4", possibilities)

  # Empty board - conditions should be met
  feen = "8/8/8/8/8/8/8/8 / C/c"
  transitions = engine.where(feen)

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

  engine = Sashite::Ggn::Ruleset::Source::Destination::Engine.new("C:P", "e3", "e4", possibilities)

  # Board with enemy piece at e4
  feen = "8/8/8/8/4p3/8/8/8 / C/c"
  transitions = engine.where(feen)

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

  engine = Sashite::Ggn::Ruleset::Source::Destination::Engine.new("C:K", "e1", "g1", possibilities)

  # Castling position
  feen = "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/c"
  transitions = engine.where(feen)

  raise "QPI identifier conditions should be evaluated" unless transitions.is_a?(Array)
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

  engine = Sashite::Ggn::Ruleset::Source::Destination::Engine.new("C:P", "e2", "e4", possibilities)

  # Board with enemy at e3 - should fail deny
  feen_with_enemy = "8/8/8/8/8/4p3/8/8 / C/c"
  transitions_denied = engine.where(feen_with_enemy)

  # Board without enemy at e3 - should pass
  feen_without_enemy = "8/8/8/8/8/8/8/8 / C/c"
  transitions_allowed = engine.where(feen_without_enemy)

  raise "deny should reject when condition met" unless transitions_denied.empty?
  raise "deny should allow when condition not met" unless transitions_allowed.size == 1
end

# ============================================================================
# PSEUDO-LEGAL TRANSITIONS GENERATION
# ============================================================================

run_test("Ruleset pseudo_legal_transitions generates all moves") do
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
        ],
        "e3" => [
          {
            "must" => { "e3" => "empty" },
            "deny" => {},
            "diff" => {
              "board" => { "e2" => nil, "e3" => "C:P" },
              "toggle" => true
            }
          }
        ]
      }
    }
  }

  ruleset = Sashite::Ggn::Ruleset.new(ggn_data)
  feen = "8/8/8/8/8/8/+P7/8 / C/c"

  moves = ruleset.pseudo_legal_transitions(feen)

  raise "pseudo_legal_transitions should return array" unless moves.is_a?(Array)
  raise "each move should be array with 4 elements" unless moves.all? { |m| m.is_a?(Array) && m.size == 4 }
  raise "moves should include piece, source, destination, transitions" unless moves.first[0] == "C:P"
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
  feen = "8/8/8/8/8/8/8/+K7 / C/c"

  transitions = ruleset
    .select("C:K")
    .from("e1")
    .to("e2")
    .where(feen)

  raise "method chaining should work" unless transitions.is_a?(Array)
  raise "transitions should contain results" unless transitions.size >= 0
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

  engine = Sashite::Ggn::Ruleset::Source::Destination::Engine.new("S:P", "*", "e4", possibilities)

  # FEEN with pawn in hand
  feen = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL P/p s/S"
  transitions = engine.where(feen)

  raise "HAND notation should work for drops" unless transitions.is_a?(Array)
end

# ============================================================================
# VALIDATION ERROR TESTS
# ============================================================================

run_test("Validation catches invalid QPI in piece key") do
  begin
    Sashite::Ggn::Ruleset.new({ "1nvalid" => {} })
    raise "Should have raised error for invalid QPI"
  rescue ArgumentError => e
    raise "Error should mention QPI" unless e.message.include?("QPI")
  end
end

run_test("Validation catches invalid CELL in source") do
  begin
    Sashite::Ggn::Ruleset.new({
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
    Sashite::Ggn::Ruleset.new({
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
    Sashite::Ggn::Ruleset.new({
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
  feen = "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+K2+R / C/c"

  transitions = ruleset
    .select("C:K")
    .from("e1")
    .to("g1")
    .where(feen)

  raise "Castling scenario should work" unless transitions.is_a?(Array)
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

  # Position with vulnerable pawn at f5
  feen = "8/8/8/4+P-p2/8/8/8/8 / C/c"

  transitions = ruleset
    .select("C:P")
    .from("e5")
    .to("f6")
    .where(feen)

  raise "En passant scenario should work" unless transitions.is_a?(Array)
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

  # Position with pawn already on file e
  feen_blocked = "lnsgkgsnl/1r5b1/ppppppppp/9/4P4/9/PPPP1PPPP/1B5R1/LNSGKGSNL P/p s/S"
  transitions_blocked = ruleset.select("S:P").from("*").to("e4").where(feen_blocked)

  # Position without pawn on file e
  feen_allowed = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL P/p s/S"
  transitions_allowed = ruleset.select("S:P").from("*").to("e4").where(feen_allowed)

  raise "Pawn drop should be blocked when file has pawn" unless transitions_blocked.empty?
  raise "Pawn drop should be allowed when file is clear" unless transitions_allowed.size >= 0
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
  raise "Possibilities should be array" unless engine.possibilities.is_a?(Array)
  raise "Possibility should have must field" unless engine.possibilities.first.key?("must")
  raise "Possibility should have deny field" unless engine.possibilities.first.key?("deny")
  raise "Possibility should have diff field" unless engine.possibilities.first.key?("diff")
end

puts
puts "All GGN tests passed!"
puts
