# Ggn.rb

[![Version](https://img.shields.io/github/v/tag/sashite/ggn.rb?label=Version&logo=github)](https://github.com/sashite/ggn.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/ggn.rb/main)
![Ruby](https://github.com/sashite/ggn.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/ggn.rb?label=License&logo=github)](https://github.com/sashite/ggn.rb/raw/main/LICENSE.md)

> **GGN** (General Gameplay Notation) implementation for the Ruby language — a rule-agnostic format for describing **movement possibilities** in abstract strategy board games.

## What is GGN?

GGN (General Gameplay Notation) is a rule-agnostic format that describes **pseudo-legal moves** in board games. It answers a fundamental question: _"Can this piece, currently at this location, reach that location?"_ — while remaining completely agnostic about game-specific rules like check, ko, or repetition.

Think of GGN as a **movement possibility oracle** that encodes:
- Which piece can move
- From which location
- To which location
- Under what pre-conditions (`must` and `deny`)
- What state changes occur (`diff` in STN format)

This gem implements the [GGN Specification v1.0.0](https://sashite.dev/specs/ggn/1.0.0/), providing a functional, immutable API for working with movement possibility data.

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

# Define movement possibilities for a chess pawn
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

# Create a movement oracle
oracle = Sashite::Ggn.parse(ggn_data)

# Query: Can white pawn move from e2 to e4?
board_state = { "e2" => "C:P", "e3" => nil, "e4" => nil }
possibilities = oracle.query("C:P", "e2", "e4", board_state)

if possibilities.any?
  transition = possibilities.first
  puts "Move is possible!"
  puts "State changes: #{transition}"
end
```

## Loading GGN Data

The gem focuses on processing GGN data structures (Ruby hashes). Loading from files is left to the user's preference:

```ruby
# Using JSON (requires 'json' gem)
require 'json'
data = JSON.parse(File.read('chess_moves.json'))
oracle = Sashite::Ggn.parse(data)

# Using YAML
require 'yaml'
data = YAML.load_file('chess_moves.yml')
oracle = Sashite::Ggn.parse(data)

# Using MessagePack
require 'msgpack'
data = MessagePack.unpack(File.read('chess_moves.msgpack'))
oracle = Sashite::Ggn.parse(data)

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
oracle = Sashite::Ggn.parse(data)
```

## GGN Format

### Structure

```ruby
{
  "<qpi-piece>" => {
    "<source-location>" => {
      "<destination-location>" => [
        {
          "must" => { "<location>" => "<required-state>", ... },
          "deny" => { "<location>" => "<forbidden-state>", ... },
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

## API Reference

### Module Methods

#### `Sashite::Ggn.parse(data) → Oracle`

Parses GGN data hash into an immutable Oracle instance.

```ruby
oracle = Sashite::Ggn.parse(ggn_data)
```

#### `Sashite::Ggn.valid?(data) → Boolean`

Validates GGN data structure.

```ruby
Sashite::Ggn.valid?(ggn_data) # => true
```

### Oracle Class

#### `#query(piece, source, destination, board_state) → Array<Transition>`

Queries movement possibilities for a specific move.

```ruby
possibilities = oracle.query("C:K", "e1", "e2", board_state)
# => [#<Sashite::Stn::Transition ...>]
```

#### `#possibilities_from(piece, source, board_state) → Hash`

Gets all possible destinations from a source location.

```ruby
destinations = oracle.possibilities_from("C:K", "e1", board_state)
# => { "e2" => [...], "d1" => [...], "f1" => [...] }
```

#### `#all_possibilities(board_state) → Array`

Generates all possible moves for the current board state.

```ruby
all_moves = oracle.all_possibilities(board_state)
# => [["C:K", "e1", "e2", [...]], ["C:Q", "d1", "d4", [...]], ...]
```

#### `#pieces → Array<String>`

Returns all piece types defined in the oracle.

```ruby
oracle.pieces # => ["C:K", "C:Q", "C:R", "C:B", "C:N", "C:P"]
```

#### `#to_h → Hash`

Returns the original GGN data structure.

```ruby
oracle.to_h # => { "C:K" => { ... } }
```

## Examples

### Simple Movement

```ruby
# King moves one square
{
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
```

### Capture

```ruby
# Pawn captures diagonally
{
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
```

### Castling (Multi-piece Movement)

```ruby
# King-side castling
{
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
```

### En Passant

```ruby
# En passant capture
{
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
            "hands" => {
              "c:p" => 1
            },
            "toggle" => true
          }
        }
      ]
    }
  }
}
```

### Promotion Choices

```ruby
# Pawn promotion to queen or knight
{
  "C:P" => {
    "e7" => {
      "e8" => [
        {
          "must" => { "e8" => "empty" },
          "deny" => {},
          "diff" => {
            "board" => { "e7" => nil, "e8" => "C:Q" },
            "toggle" => true
          }
        },
        {
          "must" => { "e8" => "empty" },
          "deny" => {},
          "diff" => {
            "board" => { "e7" => nil, "e8" => "C:N" },
            "toggle" => true
          }
        }
      ]
    }
  }
}
```

### Piece Drop (Shōgi-style)

```ruby
# Drop pawn from hand to board
{
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
```

## Working with Board State

### Board State Representation

```ruby
# Board state is a hash of location => piece
board_state = {
  "e1" => "C:K",   # White king on e1
  "d1" => "C:Q",   # White queen on d1
  "e8" => "c:k",   # Black king on e8
  "e2" => nil,     # Empty square
  "f3" => nil      # Empty square
}

# Including hand/reserve state (when relevant)
full_state = {
  board: board_state,
  hands: { "S:P" => 2, "s:p" => 1 }  # Pieces in reserve
}
```

### Evaluating Moves

```ruby
def evaluate_move(oracle, piece, from, to, board)
  possibilities = oracle.query(piece, from, to, board)

  case possibilities.size
  when 0
    puts "Move is not possible"
    nil
  when 1
    transition = possibilities.first
    puts "Move is valid"
    apply_transition(board, transition)
  else
    puts "Multiple outcomes possible (e.g., promotion)"
    # Let user choose
    possibilities
  end
end

def apply_transition(board, transition)
  new_board = board.dup

  # Apply board changes
  transition.board_changes.each do |location, piece|
    new_board[location] = piece
  end

  new_board
end
```

### Move Generation

```ruby
# Generate all pseudo-legal moves
def generate_moves(oracle, board)
  oracle.all_possibilities(board).flat_map do |piece, source, destination, transitions|
    transitions.map do |transition|
      {
        piece: piece,
        from: source,
        to: destination,
        transition: transition
      }
    end
  end
end

# Find all moves for a specific piece
def piece_moves(oracle, piece, source, board)
  oracle.possibilities_from(piece, source, board)
end
```

## Integration Examples

### Chess Engine Integration

```ruby
class ChessEngine
  def initialize(ggn_data)
    @oracle = Sashite::Ggn.parse(ggn_data)
  end

  def pseudo_legal_moves(board)
    @oracle.all_possibilities(board)
  end

  def is_move_possible?(piece, from, to, board)
    @oracle.query(piece, from, to, board).any?
  end

  def execute_move(piece, from, to, board, choice_index = 0)
    possibilities = @oracle.query(piece, from, to, board)
    return nil if possibilities.empty?

    transition = possibilities[choice_index]
    apply_stn_transition(board, transition)
  end

  private

  def apply_stn_transition(board, stn_transition)
    new_board = board.dup
    stn_transition.board_changes.each do |loc, piece|
      new_board[loc] = piece
    end
    new_board
  end
end

# Usage
require 'json'
ggn_data = JSON.parse(File.read('chess_rules.json'))
engine = ChessEngine.new(ggn_data)

board = { "e2" => "C:P", "e3" => nil, "e4" => nil }
if engine.is_move_possible?("C:P", "e2", "e4", board)
  new_board = engine.execute_move("C:P", "e2", "e4", board)
end
```

### Custom Validator

```ruby
class MoveValidator
  def initialize(ggn_data)
    @oracle = Sashite::Ggn.parse(ggn_data)
    @data = ggn_data  # Keep raw data for explanations
  end

  def validate(piece, from, to, board)
    possibilities = @oracle.query(piece, from, to, board)

    {
      valid: possibilities.any?,
      outcomes: possibilities.size,
      transitions: possibilities,
      reasons: explain_constraints(piece, from, to)
    }
  end

  private

  def explain_constraints(piece, from, to)
    return nil unless @data.dig(piece, from, to)

    @data[piece][from][to].map do |variant|
      {
        must: variant["must"],
        deny: variant["deny"]
      }
    end
  end
end
```

### Caching Oracle

```ruby
class CachedGgnOracle
  def initialize
    @oracles = {}
  end

  def load(name, data)
    @oracles[name] = Sashite::Ggn.parse(data)
  end

  def get(name)
    @oracles[name] || raise("Unknown oracle: #{name}")
  end

  def query(name, piece, from, to, board)
    get(name).query(piece, from, to, board)
  end
end

# Usage
cache = CachedGgnOracle.new

# Load different rule sets
require 'yaml'
cache.load(:chess, YAML.load_file('chess.yml'))
cache.load(:shogi, YAML.load_file('shogi.yml'))
cache.load(:xiangqi, YAML.load_file('xiangqi.yml'))

# Query specific rules
board = { "e2" => "C:P", "e4" => nil }
cache.query(:chess, "C:P", "e2", "e4", board)
```

## Design Principles

- **Functional**: Pure functions, no side effects
- **Immutable**: All data structures are frozen
- **Minimal**: No file I/O, no JSON parsing - pure data transformation
- **Composable**: Oracles can be combined or filtered
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
# Validation errors
begin
  oracle = Sashite::Ggn.parse(invalid_data)
rescue Sashite::Ggn::ValidationError => e
  puts "Invalid GGN structure: #{e.message}"
end

# Query errors
begin
  possibilities = oracle.query(piece, from, to, board)
rescue KeyError => e
  puts "Unknown piece or location: #{e.message}"
end

# Safe querying with defaults
def safe_query(oracle, piece, from, to, board)
  oracle.query(piece, from, to, board)
rescue KeyError
  []  # Return empty array if piece/location not found
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
