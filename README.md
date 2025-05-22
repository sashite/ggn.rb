# Ggn.rb

[![Version](https://img.shields.io/github/v/tag/sashite/ggn.rb?label=Version&logo=github)](https://github.com/sashite/ggn.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/ggn.rb/main)
![Ruby](https://github.com/sashite/ggn.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/ggn.rb?label=License&logo=github)](https://github.com/sashite/ggn.rb/raw/main/LICENSE.md)

> **GGN** (General Gameplay Notation) support for the Ruby language.

## What is GGN?

GGN (General Gameplay Notation) is a rule-agnostic, JSON-based format for describing **pseudo-legal moves** in abstract strategy board games. Unlike move notations that express *what* a move does, GGN expresses *whether* that move is **possible** under basic movement constraints.

GGN is deliberately silent about higher-level, game-specific legality questions (e.g., check, ko, repetition, castling paths). This neutrality makes the format universal: any engine can pre-compute and share a library of pseudo-legal moves for any mix of games.

This gem implements the [GGN Specification v1.0.0](https://sashite.dev/documents/ggn/1.0.0/), providing a Ruby interface for:

- Loading and validating GGN JSON documents
- Querying pseudo-legal moves for specific pieces and positions
- Evaluating move validity under current board conditions
- Processing complex move conditions including captures, drops, and promotions

## Installation

```ruby
# In your Gemfile
gem "sashite-ggn"
```

Or install manually:

```sh
gem install sashite-ggn
```

## GGN Format

A single GGN **entry** answers the question:

> Can this piece, currently on this square, reach that square?

It encodes:

1. **Which piece** (via GAN identifier)
2. **From where** (source square label, or "`*`" for off-board)
3. **To where** (destination square label)
4. **Which pre-conditions** must hold (`require`)
5. **Which pre-conditions** must not hold (`prevent`)
6. **Which post-conditions** result (`perform`, plus optional `gain` or `drop`)

### JSON Structure

```json
{
  "<Source piece GAN>": {
    "<Source square>": {
      "<Destination square>": [
        {
          "require":  { "<square>": "<required state>", … },
          "prevent":  { "<square>": "<forbidden state>", … },
          "perform":  { "<square>": "<new state | null>", … },
          "gain":     "<piece GAN>" | null,
          "drop":     "<piece GAN>" | null
        }
      ]
    }
  }
}
```

## Basic Usage

### Loading GGN Data

Load GGN data from various sources:

```ruby
require "sashite-ggn"

# From file
piece_data = Sashite::Ggn.load_file("chess_moves.json")

# From JSON string
json_string = '{"CHESS:P": {"e2": {"e4": [{"require": {"e3": "empty", "e4": "empty"}, "perform": {"e2": null, "e4": "CHESS:P"}}]}}}'
piece_data = Sashite::Ggn.load_string(json_string)

# From Hash
ggn_hash = { "CHESS:P" => { "e2" => { "e4" => [{ "require" => { "e3" => "empty", "e4" => "empty" }, "perform" => { "e2" => nil, "e4" => "CHESS:P" } }] } } }
piece_data = Sashite::Ggn.load_hash(ggn_hash)
```

### Querying Moves

Navigate through the GGN structure to find specific moves:

```ruby
require "sashite-ggn"

piece_data = Sashite::Ggn.load_file("chess_moves.json")

# Select a piece type
source = piece_data.select("CHESS:P")

# Get destinations from a specific source square
destinations = source.from("e2")

# Get the engine for a specific target square
engine = destinations.to("e4")
```

### Evaluating Move Validity

Check if a move is valid under current board conditions:

```ruby
require "sashite-ggn"

# Load piece data and get the movement engine
piece_data = Sashite::Ggn.load_file("chess_moves.json")
engine = piece_data.select("CHESS:P").from("e2").to("e4")

# Define current board state
board_state = {
  "e2" => "CHESS:P",  # White pawn on e2
  "e3" => nil,        # Empty square
  "e4" => nil         # Empty square
}

# Evaluate the move
result = engine.where(board_state, {}, "CHESS")

if result
  puts "Move is valid!"
  puts "Board changes: #{result.diff}"
  # => { "e2" => nil, "e4" => "CHESS:P" }
  puts "Piece gained: #{result.gain}"  # => nil (no capture)
  puts "Piece dropped: #{result.drop}" # => nil (not a drop move)
else
  puts "Move is not valid under current conditions"
end
```

### Handling Captures

Process moves that capture enemy pieces:

```ruby
require "sashite-ggn"

# Load piece data for a capture move
piece_data = Sashite::Ggn.load_file("chess_moves.json")
engine = piece_data.select("CHESS:P").from("e5").to("d6")

# Board state with enemy piece to capture
board_state = {
  "e5" => "CHESS:P",  # Our pawn
  "d6" => "chess:p"   # Enemy pawn (lowercase = opponent)
}

result = engine.where(board_state, {}, "CHESS")

if result
  puts "Capture is valid!"
  puts "Board changes: #{result.diff}"
  # => { "e5" => nil, "d6" => "CHESS:P" }
  puts "Captured piece: #{result.gain}"  # => "CHESS:P" (gained in hand)
end
```

### Piece Drops (Shogi-style)

Handle dropping pieces from hand onto the board:

```ruby
require "sashite-ggn"

# Load Shogi piece data
piece_data = Sashite::Ggn.load_file("shogi_moves.json")
engine = piece_data.select("SHOGI:P").from("*").to("5e")

# Player has captured pawns available
captures = { "SHOGI:P" => 2 }

# Current board state (5th file is clear of unpromoted pawns)
board_state = {
  "5e" => nil,  # Target square is empty
  "5a" => nil, "5b" => nil, "5c" => nil, "5d" => nil,
  "5f" => nil, "5g" => nil, "5h" => nil, "5i" => nil
}

result = engine.where(board_state, captures, "SHOGI")

if result
  puts "Pawn drop is valid!"
  puts "Board changes: #{result.diff}"  # => { "5e" => "SHOGI:P" }
  puts "Piece dropped from hand: #{result.drop}"  # => "SHOGI:P"
end
```

## Validation

### Schema Validation

Validate GGN data against the official JSON Schema:

```ruby
require "sashite-ggn"

# Validate during loading (default behavior)
begin
  piece_data = Sashite::Ggn.load_file("moves.json")
  puts "GGN data is valid!"
rescue Sashite::Ggn::ValidationError => e
  puts "Validation failed: #{e.message}"
end

# Skip validation for performance (large files)
piece_data = Sashite::Ggn.load_file("large_moves.json", validate: false)

# Validate manually
begin
  Sashite::Ggn.validate!(my_data)
  puts "Data is valid"
rescue Sashite::Ggn::ValidationError => e
  puts "Invalid: #{e.message}"
end

# Check validity without exceptions
if Sashite::Ggn.valid?(my_data)
  puts "Data is valid"
else
  errors = Sashite::Ggn.validation_errors(my_data)
  puts "Validation errors: #{errors.join(', ')}"
end
```

## Occupation States

GGN recognizes several occupation states for move conditions:

| State            | Meaning                                                                      |
| ---------------- | ---------------------------------------------------------------------------- |
| `"empty"`        | Square must be empty                                                         |
| `"enemy"`        | Square must contain a standard opposing piece                                |
| *GAN identifier* | Square must contain **exactly** the specified piece                          |

### Implicit States

Through the `prevent` field, additional states can be expressed:

| Implicit State   | Expression                   | Meaning                                                  |
| ---------------- | ---------------------------- | -------------------------------------------------------- |
| `"occupied"`     | `"prevent": { "a1": "empty" }` | Square must be occupied by any piece                     |
| `"ally"`         | `"prevent": { "a1": "enemy" }` | Square must contain a friendly piece                     |

## Examples

### Simple Move

A piece moving from one square to another without conditions:

```json
{
  "CHESS:K": {
    "e1": {
      "e2": [
        {
          "perform": { "e1": null, "e2": "CHESS:K" }
        }
      ]
    }
  }
}
```

### Sliding Move

A piece that slides along empty squares:

```json
{
  "CHESS:R": {
    "a1": {
      "a3": [
        {
          "require": { "a2": "empty", "a3": "empty" },
          "perform": { "a1": null, "a3": "CHESS:R" }
        }
      ]
    }
  }
}
```

### Capture with Gain

A piece capturing an enemy and gaining it in hand:

```json
{
  "SHOGI:P": {
    "5f": {
      "5e": [
        {
          "require": { "5e": "enemy" },
          "perform": { "5f": null, "5e": "SHOGI:P" },
          "gain": "SHOGI:P"
        }
      ]
    }
  }
}
```

### Piece Drop

Dropping a piece from hand onto the board:

```json
{
  "SHOGI:P": {
    "*": {
      "5e": [
        {
          "require": { "5e": "empty" },
          "prevent": {
            "5a": "SHOGI:P", "5b": "SHOGI:P", "5c": "SHOGI:P",
            "5d": "SHOGI:P", "5f": "SHOGI:P", "5g": "SHOGI:P",
            "5h": "SHOGI:P", "5i": "SHOGI:P"
          },
          "perform": { "5e": "SHOGI:P" },
          "drop": "SHOGI:P"
        }
      ]
    }
  }
}
```

### Promotion

A piece moving and changing to a different piece type:

```json
{
  "CHESS:P": {
    "g7": {
      "g8": [
        {
          "require": { "g8": "empty" },
          "perform": { "g7": null, "g8": "CHESS:Q" }
        }
      ]
    }
  }
}
```

## Error Handling

The library provides comprehensive error handling:

```ruby
require "sashite-ggn"

begin
  # Various operations that might fail
  piece_data = Sashite::Ggn.load_file("nonexistent.json")
  source = piece_data.select("INVALID:PIECE")
  destinations = source.from("invalid_square")
  engine = destinations.to("another_invalid")
  result = engine.where({}, {}, "")
rescue Sashite::Ggn::ValidationError => e
  puts "GGN validation error: #{e.message}"
rescue KeyError => e
  puts "Key not found: #{e.message}"
rescue ArgumentError => e
  puts "Invalid argument: #{e.message}"
end
```

## Performance Considerations

For large GGN files or high-frequency operations:

```ruby
# Skip validation for better performance
piece_data = Sashite::Ggn.load_file("large_dataset.json", validate: false)

# Cache frequently used engines
@engines = {}
def get_engine(piece, from, to)
  key = "#{piece}:#{from}:#{to}"
  @engines[key] ||= piece_data.select(piece).from(from).to(to)
end
```

## Related Specifications

GGN works alongside other Sashité specifications:

- [GAN](https://sashite.dev/documents/gan/) (General Actor Notation): Unique piece identifiers
- [FEEN](https://sashite.dev/documents/feen/) (Forsyth-Edwards Enhanced Notation): Board position representation
- [PMN](https://sashite.dev/documents/pmn/) (Portable Move Notation): Move sequence representation

## Documentation

- [Official GGN Specification](https://sashite.dev/documents/ggn/)
- [JSON Schema](https://sashite.dev/schemas/ggn/1.0.0/schema.json)
- [API Documentation](https://rubydoc.info/github/sashite/ggn.rb/main)

## License

The [gem](https://rubygems.org/gems/sashite-ggn) is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This project is maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of Chinese, Japanese, and Western chess cultures.
