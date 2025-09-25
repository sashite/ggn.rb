# Ggn.rb

[![Version](https://img.shields.io/github/v/tag/sashite/ggn.rb?label=Version&logo=github)](https://github.com/sashite/ggn.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/ggn.rb/main)
![Ruby](https://github.com/sashite/ggn.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/ggn.rb?label=License&logo=github)](https://github.com/sashite/ggn.rb/raw/main/LICENSE.md)

> **GGN** (General Gameplay Notation) implementation for the Ruby language — a pure, functional library for evaluating **movement possibilities** in abstract strategy board games.

## What is GGN?

GGN (General Gameplay Notation) is a rule-agnostic format that describes **pseudo-legal moves** in board games. It answers: _"Can this piece, currently at this location, reach that location?"_ — while remaining agnostic about game-specific rules like check, ko, or repetition.

GGN serves as a **movement possibility oracle** that encodes:
- Which piece can move
- From which location
- To which location
- Under what pre-conditions (`must` and `deny`)
- What state changes occur (`diff` in STN format)

This gem implements the [GGN Specification v1.0.0](https://sashite.dev/specs/ggn/1.0.0/), providing a pure functional API for working with movement possibilities.

## Installation

```ruby
# In your Gemfile
gem "sashite-ggn"
```

Or install manually:

```sh
gem install sashite-ggn
```

## Dependencies

GGN builds upon the Sashité specification ecosystem:

- **[sashite-cell](https://github.com/sashite/cell.rb)** — Multi-dimensional coordinate encoding
- **[sashite-hand](https://github.com/sashite/hand.rb)** — Reserve location notation
- **[sashite-qpi](https://github.com/sashite/qpi.rb)** — Qualified Piece Identifier
- **[sashite-stn](https://github.com/sashite/stn.rb)** — State Transition Notation

## Quick Start

```ruby
require "sashite/ggn"

# GGN data as a Ruby hash (loaded externally)
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

# Create a ruleset from the GGN data
ruleset = Sashite::Ggn.parse(ggn_data)

# Navigate through the movement hierarchy
engine = ruleset.select("C:P").from("e2").to("e4")

# Evaluate the move
board_state = { "e2" => "C:P", "e3" => nil, "e4" => nil }
transitions = engine.where(board_state)

if transitions.any?
  puts "Move is possible!"
  transitions.each { |t| puts "State changes: #{t}" }
end
```

## API Reference

### Main Module

#### `Sashite::Ggn.parse(data) → Ruleset`

Creates a Ruleset from GGN data hash.

```ruby
ruleset = Sashite::Ggn.parse(ggn_data)
```

#### `Sashite::Ggn.valid?(data) → Boolean`

Validates GGN data structure against the specification.

```ruby
Sashite::Ggn.valid?(ggn_data) # => true
```

### Navigation Chain

The API follows GGN's hierarchical structure through method chaining:

```ruby
ruleset.select(piece)    # → Source
       .from(origin)     # → Destination
       .to(target)       # → Engine
       .where(board)     # → Array<Transition>
```

### Ruleset Class

The entry point for querying movement rules.

#### `#select(piece) → Source`

Selects movement rules for a specific piece type.

```ruby
source = ruleset.select("C:K")  # Chess king
source = ruleset.select("s:+p") # Shogi promoted pawn (gote)
```

#### `#pseudo_legal_transitions(board_state) → Array`

Generates all possible moves for the current position.

```ruby
all_moves = ruleset.pseudo_legal_transitions(board_state)
# => [["C:K", "e1", "e2", [...]], ["C:Q", "d1", "d4", [...]], ...]

all_moves.each do |piece, from, to, transitions|
  puts "#{piece}: #{from} → #{to} (#{transitions.size} variants)"
end
```

### Source Class

Represents possible source positions for a piece type.

#### `#from(origin) → Destination`

Gets possible destinations from a source position.

```ruby
destinations = source.from("e1")
```

### Destination Class

Represents possible destination squares from a source.

#### `#to(target) → Engine`

Creates an engine for evaluating a specific move.

```ruby
engine = destinations.to("e2")
```

### Engine Class

Evaluates move validity under given board conditions.

#### `#where(board_state) → Array<Transition>`

Returns valid transitions for the current board state.

```ruby
board = { "e1" => "C:K", "e2" => nil }
transitions = engine.where(board)
# => [#<Sashite::Stn::Transition ...>]
```

### Transition Class (from sashite-stn)

Represents state changes from a move.

```ruby
transition = transitions.first
transition.board_changes  # => { "e1" => nil, "e2" => "C:K" }
transition.hand_changes   # => {}
transition.toggle?        # => true
```

## GGN Format

### Structure

```ruby
{
  "<qpi-piece>" => {
    "<source-location>" => {
      "<destination-location>" => [
        {
          "must" => { "<location>" => "<state>", ... },
          "deny" => { "<location>" => "<state>", ... },
          "diff" => { /* STN format */ }
        }
      ]
    }
  }
}
```

### Core Components

| Field | Type | Description |
|-------|------|-------------|
| **Piece** | QPI string | Piece identifier (e.g., `"C:K"`, `"s:+p"`) |
| **Source** | CELL or "*" | Origin location |
| **Destination** | CELL or "*" | Target location |
| **must** | Hash | Pre-conditions that must be satisfied (AND logic) |
| **deny** | Hash | Pre-conditions that must not be satisfied (OR logic) |
| **diff** | Hash | State transition in STN format |

### Location States

| State | Meaning |
|-------|---------|
| `"empty"` | Location must be empty |
| `"enemy"` | Location must contain an opposing piece |
| QPI string | Location must contain exactly this piece |

## Usage Examples

### Simple Movement

```ruby
# King moves one square
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
board = { "e1" => "C:K", "e2" => nil }

transitions = ruleset.select("C:K").from("e1").to("e2").where(board)
```

### Capture

```ruby
# Pawn captures diagonally
ggn_data = {
  "C:P" => {
    "e4" => {
      "f5" => [
        {
          "must" => { "f5" => "enemy" },
          "deny" => {},
          "diff" => {
            "board" => { "e4" => nil, "f5" => "C:P" },
            "toggle" => true
          }
        }
      ]
    }
  }
}

ruleset = Sashite::Ggn.parse(ggn_data)
board = { "e4" => "C:P", "f5" => "c:p" }

transitions = ruleset.select("C:P").from("e4").to("f5").where(board)
```

### Promotion Choices

```ruby
# Pawn promotion with multiple outcomes
ggn_data = {
  "C:P" => {
    "e7" => {
      "e8" => [
        {
          "must" => { "e8" => "empty" },
          "deny" => {},
          "diff" => { "board" => { "e7" => nil, "e8" => "C:Q" }, "toggle" => true }
        },
        {
          "must" => { "e8" => "empty" },
          "deny" => {},
          "diff" => { "board" => { "e7" => nil, "e8" => "C:N" }, "toggle" => true }
        }
      ]
    }
  }
}

ruleset = Sashite::Ggn.parse(ggn_data)
board = { "e7" => "C:P", "e8" => nil }

transitions = ruleset.select("C:P").from("e7").to("e8").where(board)

transitions.each_with_index do |t, i|
  promoted_piece = t.board_changes["e8"]
  puts "Choice #{i + 1}: promotes to #{promoted_piece}"
end
# => Choice 1: promotes to C:Q
# => Choice 2: promotes to C:N
```

### Complex Moves (Castling)

```ruby
# King-side castling
ggn_data = {
  "C:+K" => {
    "e1" => {
      "g1" => [
        {
          "must" => {
            "f1" => "empty",
            "g1" => "empty",
            "h1" => "C:+R"
          },
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

ruleset = Sashite::Ggn.parse(ggn_data)
board = { "e1" => "C:+K", "f1" => nil, "g1" => nil, "h1" => "C:+R" }

transitions = ruleset.select("C:+K").from("e1").to("g1").where(board)

if transitions.any?
  puts "Castling is possible!"
  puts "Result: #{transitions.first.board_changes}"
  # => {"e1"=>nil, "g1"=>"C:K", "h1"=>nil, "f1"=>"C:R"}
end
```

### En Passant

```ruby
# En passant capture
ggn_data = {
  "C:P" => {
    "e5" => {
      "f6" => [
        {
          "must" => {
            "f6" => "empty",
            "f5" => "c:-p"  # Vulnerable pawn
          },
          "deny" => {},
          "diff" => {
            "board" => {
              "e5" => nil,
              "f6" => "C:P",
              "f5" => nil
            },
            "hands" => { "c:p" => 1 },
            "toggle" => true
          }
        }
      ]
    }
  }
}

ruleset = Sashite::Ggn.parse(ggn_data)
board = { "e5" => "C:P", "f5" => "c:-p", "f6" => nil }

transitions = ruleset.select("C:P").from("e5").to("f6").where(board)
```

### Piece Drop (Shōgi-style)

```ruby
# Drop pawn from hand with file restriction
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

ruleset = Sashite::Ggn.parse(ggn_data)
board = { "e4" => nil, "e5" => nil }  # No pawns on file

transitions = ruleset.select("S:P").from("*").to("e4").where(board)
```

## Working with Board State

```ruby
# Board state representation
board_state = {
  "e1" => "C:K",   # White king on e1
  "d1" => "C:Q",   # White queen on d1
  "e8" => "c:k",   # Black king on e8
  "e2" => nil,     # Empty square
  "f3" => nil      # Empty square
}

# Generate all moves for a position
ruleset = Sashite::Ggn.parse(ggn_data)
all_moves = ruleset.pseudo_legal_transitions(board_state)

all_moves.each do |piece, from, to, transitions|
  puts "#{piece}: #{from} → #{to} (#{transitions.size} variants)"
end

# Check specific piece moves
king_moves = ruleset.select("C:K").from("e1")
queen_moves = ruleset.select("C:Q").from("d1")
```

## Loading GGN Data

The gem focuses on processing GGN data structures. Loading from files is left to user preference:

```ruby
# Using JSON (requires 'json' gem)
require 'json'
data = JSON.parse(File.read('chess_moves.json'))
ruleset = Sashite::Ggn.parse(data)

# Using YAML
require 'yaml'
data = YAML.load_file('chess_moves.yml')
ruleset = Sashite::Ggn.parse(data)

# Using MessagePack
require 'msgpack'
data = MessagePack.unpack(File.read('chess_moves.msgpack'))
ruleset = Sashite::Ggn.parse(data)

# Direct Ruby hash
data = {
  "C:K" => {
    "e1" => {
      "e2" => [
        {
          "must" => { "e2" => "empty" },
          "deny" => {},
          "diff" => { "board" => { "e1" => nil, "e2" => "C:K" }, "toggle" => true }
        }
      ]
    }
  }
}
ruleset = Sashite::Ggn.parse(data)
```

## Advanced Usage

### Move Generation and Filtering

```ruby
# Generate all pseudo-legal moves
all_moves = ruleset.pseudo_legal_transitions(board_state)

# Filter for specific piece type
king_moves = all_moves.select { |piece, _, _, _| piece == "C:K" }

# Filter for captures
captures = all_moves.select do |_, _, _, transitions|
  transitions.any? { |t| t.board_changes.values.compact.size > 1 }
end

# Filter for promotion moves
promotions = all_moves.select do |piece, _, _, transitions|
  transitions.size > 1  # Multiple choices indicate promotion
end
```

### Building Game Engines

```ruby
class ChessEngine
  def initialize(ggn_data)
    @ruleset = Sashite::Ggn.parse(ggn_data)
  end

  def pseudo_legal_moves(board)
    @ruleset.pseudo_legal_transitions(board)
  end

  def valid_move?(piece, from, to, board)
    @ruleset.select(piece).from(from).to(to).where(board).any?
  rescue KeyError
    false
  end

  def make_move(piece, from, to, board, choice_index = 0)
    transitions = @ruleset.select(piece).from(from).to(to).where(board)
    return nil if transitions.empty?

    transition = transitions[choice_index]
    apply_transition(board, transition)
  end

  private

  def apply_transition(board, transition)
    new_board = board.dup
    transition.board_changes.each { |square, piece| new_board[square] = piece }
    new_board
  end
end

# Usage
engine = ChessEngine.new(chess_ggn_data)
board = { "e2" => "C:P", "e3" => nil, "e4" => nil }

if engine.valid_move?("C:P", "e2", "e4", board)
  new_board = engine.make_move("C:P", "e2", "e4", board)
end
```

### Hybrid Games Support

```ruby
# Mix pieces from different game systems
hybrid_ggn = {
  "C:K" => { /* chess king rules */ },
  "S:G" => { /* shogi gold general rules */ },
  "X:C" => { /* xiangqi cannon rules */ }
}

ruleset = Sashite::Ggn.parse(hybrid_ggn)

# Each piece follows its own movement rules
chess_king = ruleset.select("C:K").from("e1")
shogi_gold = ruleset.select("S:G").from("5e")
xiangqi_cannon = ruleset.select("X:C").from("e5")
```

## Design Principles

- **Functional**: Pure functions, no side effects
- **Immutable**: All data structures are frozen
- **Minimal**: No file I/O, no JSON parsing - pure data transformation
- **Composable**: Method chaining for natural navigation
- **Spec-compliant**: Strictly follows GGN v1.0.0 specification
- **Delegative**: Leverages sashite-cell, sashite-qpi, sashite-stn for validation

## Performance Characteristics

- **O(1)** piece lookup
- **O(1)** source-destination query
- **O(n)** pre-condition evaluation (n = number of must/deny conditions)
- **Immutable data structures** ensure thread safety
- **No parsing overhead** - works with Ruby hashes directly

## Error Handling

```ruby
# Query for non-existent piece
begin
  source = ruleset.select("INVALID:X")
rescue KeyError => e
  puts "Unknown piece: #{e.message}"
end

# Query for invalid position
begin
  destinations = source.from("invalid_square")
rescue KeyError => e
  puts "Invalid source position: #{e.message}"
end

# Safe querying with defaults
def safe_move_check(ruleset, piece, from, to, board)
  ruleset.select(piece).from(from).to(to).where(board)
rescue KeyError
  []  # Return empty array if piece/location not found
end

# Validate data before parsing
if Sashite::Ggn.valid?(ggn_data)
  ruleset = Sashite::Ggn.parse(ggn_data)
else
  puts "Invalid GGN data structure"
end
```

## Related Specifications

GGN is part of the Sashité ecosystem:

- [GGN v1.0.0](https://sashite.dev/specs/ggn/1.0.0/) — General Gameplay Notation specification
- [CELL v1.0.0](https://sashite.dev/specs/cell/1.0.0/) — Coordinate encoding
- [HAND v1.0.0](https://sashite.dev/specs/hand/1.0.0/) — Reserve notation
- [QPI v1.0.0](https://sashite.dev/specs/qpi/1.0.0/) — Piece identification
- [STN v1.0.0](https://sashite.dev/specs/stn/1.0.0/) — State transitions

## Development

```sh
# Clone the repository
git clone https://github.com/sashite/ggn.rb.git
cd ggn.rb

# Install dependencies
bundle install

# Run tests
bundle exec rake test

# Generate documentation
yard doc
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Add tests for your changes
4. Ensure all tests pass
5. Commit your changes (`git commit -am 'Add new feature'`)
6. Push to the branch (`git push origin feature/new-feature`)
7. Create a Pull Request

## License

Available as open source under the [MIT License](https://opensource.org/licenses/MIT).

## About

Maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of board game cultures.
