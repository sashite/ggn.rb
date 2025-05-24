# frozen_string_literal: true

require_relative "../../lib/sashite-ggn"
require 'tempfile'
require 'json'

puts "=== MINIMAL GGN TEST SUITE ==="

# Test data
VALID_DATA = {
  "CHESS:P" => {
    "e2" => {
      "e4" => [{ "require" => { "e3" => "empty", "e4" => "empty" }, "perform" => { "e2" => nil, "e4" => "CHESS:P" } }],
      "f3" => [{ "require" => { "f3" => "enemy" }, "perform" => { "e2" => nil, "f3" => "CHESS:P" }, "gain" => "CHESS:P" }]
    },
    "e7" => {
      "e8" => [
        { "require" => { "e8" => "empty" }, "perform" => { "e7" => nil, "e8" => "CHESS:Q" } },
        { "require" => { "e8" => "empty" }, "perform" => { "e7" => nil, "e8" => "CHESS:R" } }
      ]
    }
  },
  "SHOGI:P" => {
    "*" => {
      "5e" => [{ "require" => { "5e" => "empty" }, "perform" => { "5e" => "SHOGI:P" }, "drop" => "SHOGI:P" }]
    }
  }
}.freeze

INVALID_DATA = {
  "CHESS:P" => { "e2" => { "e4" => [{ "require" => { "e4" => "empty" } }] } }  # Missing perform
}.freeze

def create_temp_file(data)
  file = Tempfile.new(['test', '.json'])
  file.write(JSON.generate(data))
  file.close
  file
end

puts "Testing module methods..."

# Module loading tests
json_string = JSON.generate(VALID_DATA)
ruleset = Sashite::Ggn.load_string(json_string)
raise unless ruleset.is_a?(Sashite::Ggn::Ruleset)

ruleset = Sashite::Ggn.load_hash(VALID_DATA)
raise unless ruleset.is_a?(Sashite::Ggn::Ruleset)

temp_file = create_temp_file(VALID_DATA)
begin
  ruleset = Sashite::Ggn.load_file(temp_file.path)
  raise unless ruleset.is_a?(Sashite::Ggn::Ruleset)
ensure
  temp_file.unlink
end

# Validation tests
raise unless Sashite::Ggn.valid?(VALID_DATA)
raise if Sashite::Ggn.valid?(INVALID_DATA)

begin
  Sashite::Ggn.validate!(INVALID_DATA)
  raise "Should have failed"
rescue Sashite::Ggn::ValidationError
  # Expected
end

puts "✓ Module methods work"

puts "Testing core classes..."

# Ruleset tests
ruleset = Sashite::Ggn::Ruleset.new(VALID_DATA)
source = ruleset.select("CHESS:P")
raise unless source.is_a?(Sashite::Ggn::Ruleset::Source)

begin
  ruleset.select("NONEXISTENT:X")
  raise "Should have failed"
rescue KeyError
  # Expected
end

# Source tests
destination = source.from("e2")
raise unless destination.is_a?(Sashite::Ggn::Ruleset::Source::Destination)

# Destination tests
engine = destination.to("e4")
raise unless engine.is_a?(Sashite::Ggn::Ruleset::Source::Destination::Engine)

puts "✓ Core classes work"

puts "Testing move evaluation..."

# Valid move
board = { "e2" => "CHESS:P", "e3" => nil, "e4" => nil }
results = engine.where(board, {}, "CHESS")
raise unless results.size == 1
transition = results.first
raise unless transition.diff == { "e2" => nil, "e4" => "CHESS:P" }
raise if transition.gain?

# Blocked move
blocked_board = { "e2" => "CHESS:P", "e3" => "CHESS:N", "e4" => nil }
results = engine.where(blocked_board, {}, "CHESS")
raise unless results.empty?

# Capture
capture_engine = destination.to("f3")
capture_board = { "e2" => "CHESS:P", "f3" => "chess:p" }
results = capture_engine.where(capture_board, {}, "CHESS")
raise unless results.size == 1
raise unless results.first.gain == "CHESS:P"

# Multiple promotion choices
promotion_engine = source.from("e7").to("e8")
promotion_board = { "e7" => "CHESS:P", "e8" => nil }
results = promotion_engine.where(promotion_board, {}, "CHESS")
raise unless results.size == 2  # Q and R variants in test data

puts "✓ Move evaluation works"

puts "Testing Shogi drops..."

# Valid drop
shogi_source = ruleset.select("SHOGI:P")
drop_engine = shogi_source.from("*").to("5e")
drop_board = { "5e" => nil }
captures = { "SHOGI:P" => 1 }
results = drop_engine.where(drop_board, captures, "SHOGI")
raise unless results.size == 1
raise unless results.first.drop == "SHOGI:P"

# No piece in hand
results = drop_engine.where(drop_board, {}, "SHOGI")
raise unless results.empty?

puts "✓ Shogi drops work"

puts "Testing pseudo_legal_transitions..."

# Basic functionality
board = { "e2" => "CHESS:P", "e3" => nil, "e4" => nil, "f3" => nil }
moves = ruleset.pseudo_legal_transitions(board, {}, "CHESS")
raise unless moves.is_a?(Array)
raise if moves.empty?

# Structure validation
actor, origin, target, transitions = moves.first
raise unless actor.is_a?(String)
raise unless origin.is_a?(String)
raise unless target.is_a?(String)
raise unless transitions.is_a?(Array)

# No moves for wrong player
moves = ruleset.pseudo_legal_transitions(board, {}, "shogi")
raise unless moves.empty?

puts "✓ pseudo_legal_transitions works"

puts "Testing error handling..."

# Invalid parameters
begin
  ruleset.pseudo_legal_transitions("not hash", {}, "CHESS")
  raise "Should have failed"
rescue ArgumentError
  # Expected
end

begin
  engine.where({}, {}, "")
  raise "Should have failed"
rescue ArgumentError
  # Expected
end

# Invalid constructors
begin
  Sashite::Ggn.load_hash("not hash")
  raise "Should have failed"
rescue Sashite::Ggn::ValidationError
  # Expected
end

begin
  Sashite::Ggn::Ruleset.new("not hash")
  raise "Should have failed"
rescue ArgumentError
  # Expected
end

puts "✓ Error handling works"

puts "Testing Transition class..."

transition = Sashite::Ggn::Ruleset::Source::Destination::Engine::Transition.new(
  "CHESS:R", "CHESS:P", "e2" => nil, "e4" => "CHESS:Q"
)

raise unless transition.gain == "CHESS:R"
raise unless transition.drop == "CHESS:P"
raise unless transition.diff == { "e2" => nil, "e4" => "CHESS:Q" }
raise unless transition.gain?
raise unless transition.drop?

simple_transition = Sashite::Ggn::Ruleset::Source::Destination::Engine::Transition.new(
  nil, nil, "e2" => nil, "e3" => "CHESS:P"
)
raise if simple_transition.gain?
raise if simple_transition.drop?

puts "✓ Transition class works"

puts "\n✅ ALL TESTS PASSED!"
puts "Tested: Module methods, Core classes, Move evaluation, Drops, Error handling"
puts "Coverage: Load/validate, Select/navigate, Engine evaluation, Transitions"
