# Ggn.rb

A Ruby implementation of the General Gameplay Notation (GGN) specification for describing pseudo-legal moves in abstract strategy board games.

[![Gem Version](https://badge.fury.io/rb/sashite-ggn.svg)](https://badge.fury.io/rb/sashite-ggn)
[![Ruby](https://github.com/sashite/ggn.rb/workflows/Ruby/badge.svg)](https://github.com/sashite/ggn.rb/actions)

## What is GGN?

GGN (General Gameplay Notation) is a rule-agnostic, JSON-based format for representing pseudo-legal moves in abstract strategy board games. This gem implements the [GGN Specification v1.0.0](https://sashite.dev/documents/ggn/1.0.0/).

GGN focuses on basic movement constraints rather than game-specific legality rules, making it suitable for:

- Cross-game move analysis and engine development
- Hybrid games combining elements from different chess variants
- Database systems requiring piece disambiguation across game types
- Performance-critical applications with pre-computed move libraries

## Installation

```ruby
gem 'sashite-ggn'
```

## Basic Usage

### Loading GGN Data

```ruby
require "sashite-ggn"

# Load from file
ruleset = Sashite::Ggn.load_file("chess_moves.json")

# Load from string
json = '{"CHESS:P": {"e2": {"e4": [{"perform": {"e2": null, "e4": "CHESS:P"}}]}}}'
ruleset = Sashite::Ggn.load_string(json)
```

### Evaluating Moves

```ruby
# Query specific move
engine = ruleset.select("CHESS:P").from("e2").to("e4")

# Define board state
board_state = { "e2" => "CHESS:P", "e3" => nil, "e4" => nil }

# Evaluate move
transitions = engine.where(board_state, {}, "CHESS")
# => [#<Transition diff={"e2"=>nil, "e4"=>"CHESS:P"}>]
```

### Generating All Moves

```ruby
# Get all pseudo-legal moves for current position
all_moves = ruleset.pseudo_legal_transitions(board_state, captures, "CHESS")

# Each move is represented as [actor, origin, target, transitions]
all_moves.each do |actor, origin, target, transitions|
  puts "#{actor}: #{origin} → #{target} (#{transitions.size} variants)"
end
```

## Move Variants

GGN supports multiple outcomes for a single move (e.g., promotion choices):

```ruby
# Chess pawn promotion
engine = ruleset.select("CHESS:P").from("e7").to("e8")
transitions = engine.where({"e7" => "CHESS:P", "e8" => nil}, {}, "CHESS")

transitions.each do |transition|
  promoted_piece = transition.diff["e8"]
  puts "Promote to #{promoted_piece}"
end
# Output: CHESS:Q, CHESS:R, CHESS:B, CHESS:N
```

## Piece Drops

For games supporting piece drops (e.g., Shogi):

```ruby
# Drop from hand (origin "*")
engine = ruleset.select("SHOGI:P").from("*").to("5e")

captures = { "SHOGI:P" => 1 }  # One pawn in hand
board_state = { "5e" => nil }   # Empty target square

transitions = engine.where(board_state, captures, "SHOGI")
# => [#<Transition diff={"5e"=>"SHOGI:P"} drop="SHOGI:P">]
```

## Validation

```ruby
# Validate GGN data
Sashite::Ggn.validate!(data)  # Raises exception on failure
Sashite::Ggn.valid?(data)     # Returns boolean
```

## API Reference

### Core Classes

- `Sashite::Ggn::Ruleset` - Main entry point for querying moves
- `Sashite::Ggn::Ruleset::Source` - Piece type with source positions
- `Sashite::Ggn::Ruleset::Source::Destination` - Available destinations
- `Sashite::Ggn::Ruleset::Source::Destination::Engine` - Move evaluator
- `Sashite::Ggn::Ruleset::Source::Destination::Engine::Transition` - Move result

### Key Methods

- `#pseudo_legal_transitions(board_state, captures, turn)` - Generate all moves
- `#select(actor).from(origin).to(target)` - Query specific move
- `#where(board_state, captures, turn)` - Evaluate move validity

## Related Specifications

GGN works alongside other Sashité specifications:

- [GAN](https://sashite.dev/documents/gan/1.0.0/) - General Actor Notation for piece identifiers
- [FEEN](https://sashite.dev/documents/feen/1.0.0/) - Board position representation
- [PMN](https://sashite.dev/documents/pmn/1.0.0/) - Move sequence representation

## License

The [gem](https://rubygems.org/gems/sashite-ggn) is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This project is maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of Chinese, Japanese, and Western chess cultures.
