# Ggn.rb

[![Version](https://img.shields.io/github/v/tag/sashite/ggn.rb?label=Version&logo=github)](https://github.com/sashite/ggn.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/ggn.rb/main)
![Ruby](https://github.com/sashite/ggn.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/ggn.rb?label=License&logo=github)](https://github.com/sashite/ggn.rb/raw/main/LICENSE.md)

> **GGN** (General Gameplay Notation) implementation for Ruby — evaluates **movement possibilities** in abstract strategy board games.

## What is GGN?

GGN (General Gameplay Notation) is a rule-agnostic format for describing **pseudo-legal moves** in abstract strategy board games. GGN serves as a **movement possibility oracle**: given a piece at a source location and a desired destination, it determines if the movement is feasible based on environmental pre-conditions.

This gem implements the [GGN Specification v1.0.0](https://sashite.dev/specs/ggn/1.0.0/).

## Installation

```ruby
# In your Gemfile
gem "sashite-ggn"
```

Or install manually:

```sh
gem install sashite-ggn
```

## Quick Start

```ruby
require "sashite/ggn"

# Define GGN data structure
ggn_data = {
  "C:P" => {                              # Chess pawn
    "e2" => {                             # From e2
      "e4" => [                           # To e4
        {
          "must" => {                     # Required conditions
            "e3" => "empty",
            "e4" => "empty"
          },
          "deny" => {}                    # Forbidden conditions
        }
      ]
    }
  }
}

# Parse into ruleset
ruleset = Sashite::Ggn.parse(ggn_data)

# Query movement through method chaining
active_side = :first
squares = { "e2" => "C:P", "e3" => nil, "e4" => nil }

possibilities = ruleset
  .select("C:P")        # Select piece type
  .from("e2")           # From source location
  .to("e4")             # To destination location
  .where(active_side, squares)  # Evaluate conditions

possibilities.any?      # => true (movement is possible)
```

## Core Concepts

### Navigation Structure

GGN uses a hierarchical structure that naturally maps to method chaining:

```
Piece → Source → Destination → Possibilities
```

Each level provides introspection methods to explore available options:

```ruby
# Explore available pieces
ruleset.pieces                    # => ["C:K", "C:Q", "C:P", ...]

# Explore sources for a piece
ruleset.select("C:P").sources     # => ["a2", "b2", "c2", ...]

# Explore destinations from a source
ruleset.select("C:P").from("e2").destinations  # => ["e3", "e4"]

# Check existence at any level
ruleset.piece?("C:K")                          # => true
ruleset.select("C:K").source?("e1")             # => true
ruleset.select("C:K").from("e1").destination?("e2")  # => true
```

### Condition Evaluation

The `where` method evaluates movement possibilities against the current board state:

```ruby
# Returns array of matching possibilities (may be empty)
possibilities = engine.where(active_side, squares)

# Each possibility is a Hash containing the original GGN data
# that satisfied the conditions
possibility = possibilities.first
# => { "must" => {...}, "deny" => {...} }
```

**Key points:**
- `active_side` (Symbol): `:first` or `:second` - determines enemy evaluation
- `squares` (Hash): Board state where keys are CELL coordinates, values are QPI identifiers or `nil`
- Returns an array of possibilities that match the conditions

## API Reference

### Module Methods

```ruby
# Parse GGN data into a ruleset
ruleset = Sashite::Ggn.parse(data)

# Validate GGN data structure
Sashite::Ggn.valid?(data)  # => true/false
```

### Ruleset Class

```ruby
# Select piece movement rules
source = ruleset.select("C:K")

# Check if piece exists
ruleset.piece?("C:K")  # => true/false

# List all pieces
ruleset.pieces  # => ["C:K", "C:Q", ...]
```

### Source Class

```ruby
# Select source location
destination = source.from("e1")

# Check if source exists
source.source?("e1")  # => true/false

# List all sources
source.sources  # => ["e1", "d1", ...]
```

### Destination Class

```ruby
# Select destination location
engine = destination.to("e2")

# Check if destination exists
destination.destination?("e2")  # => true/false

# List all destinations
destination.destinations  # => ["d1", "d2", ...]
```

### Engine Class

```ruby
# Evaluate movement possibilities
possibilities = engine.where(active_side, squares)
# Returns array of possibility hashes that match conditions
```

## Examples

### Chess Pawn Movement

```ruby
# Two-square advance from starting position
ggn_data = {
  "C:P" => {
    "e2" => {
      "e4" => [{
        "must" => { "e3" => "empty", "e4" => "empty" },
        "deny" => {}
      }]
    }
  }
}

ruleset = Sashite::Ggn.parse(ggn_data)

# Valid: path is clear
squares = { "e2" => "C:P", "e3" => nil, "e4" => nil }
possibilities = ruleset.select("C:P").from("e2").to("e4").where(:first, squares)
possibilities.any?  # => true

# Invalid: e3 is blocked
squares = { "e2" => "C:P", "e3" => "c:p", "e4" => nil }
possibilities = ruleset.select("C:P").from("e2").to("e4").where(:first, squares)
possibilities.any?  # => false
```

### Pawn Capture

```ruby
# Diagonal capture
ggn_data = {
  "C:P" => {
    "e4" => {
      "d5" => [{
        "must" => { "d5" => "enemy" },
        "deny" => {}
      }]
    }
  }
}

ruleset = Sashite::Ggn.parse(ggn_data)

# Valid: enemy piece on d5
squares = { "e4" => "C:P", "d5" => "c:p" }
possibilities = ruleset.select("C:P").from("e4").to("d5").where(:first, squares)
possibilities.any?  # => true

# Invalid: friendly piece on d5
squares = { "e4" => "C:P", "d5" => "C:N" }
possibilities = ruleset.select("C:P").from("e4").to("d5").where(:first, squares)
possibilities.any?  # => false
```

### Castling

```ruby
# King-side castling
ggn_data = {
  "C:K" => {
    "e1" => {
      "g1" => [{
        "must" => {
          "f1" => "empty",
          "g1" => "empty",
          "h1" => "C:+R"     # Rook with castling rights
        },
        "deny" => {}
      }]
    }
  }
}

ruleset = Sashite::Ggn.parse(ggn_data)

# Valid: all conditions met
squares = {
  "e1" => "C:+K",
  "f1" => nil,
  "g1" => nil,
  "h1" => "C:+R"
}
possibilities = ruleset.select("C:K").from("e1").to("g1").where(:first, squares)
possibilities.any?  # => true
```

### Shogi Drop

```ruby
# Pawn drop with file restriction
ggn_data = {
  "S:P" => {
    "*" => {              # From hand
      "e4" => [{
        "must" => { "e4" => "empty" },
        "deny" => {       # No friendly pawn on same file
          "e1" => "S:P", "e2" => "S:P", "e3" => "S:P",
          "e5" => "S:P", "e6" => "S:P", "e7" => "S:P",
          "e8" => "S:P", "e9" => "S:P"
        }
      }]
    }
  }
}

ruleset = Sashite::Ggn.parse(ggn_data)

# Valid: no pawn on e-file
squares = {
  "e1" => nil, "e2" => nil, "e3" => nil, "e4" => nil,
  "e5" => nil, "e6" => nil, "e7" => nil, "e8" => nil, "e9" => nil
}
possibilities = ruleset.select("S:P").from("*").to("e4").where(:first, squares)
possibilities.any?  # => true

# Invalid: pawn already on e5
squares["e5"] = "S:P"
possibilities = ruleset.select("S:P").from("*").to("e4").where(:first, squares)
possibilities.any?  # => false
```

### En Passant

```ruby
# En passant capture
ggn_data = {
  "C:P" => {
    "e5" => {
      "f6" => [{
        "must" => {
          "f6" => "empty",
          "f5" => "c:-p"    # Enemy pawn vulnerable to en passant
        },
        "deny" => {}
      }]
    }
  }
}

ruleset = Sashite::Ggn.parse(ggn_data)

squares = {
  "e5" => "C:P",
  "f5" => "c:-p",
  "f6" => nil
}
possibilities = ruleset.select("C:P").from("e5").to("f6").where(:first, squares)
possibilities.any?  # => true
```

## Error Handling

```ruby
# Missing piece
begin
  ruleset.select("X:Y")
rescue KeyError => e
  puts e.message  # => "Piece not found: X:Y"
end

# Missing source
begin
  ruleset.select("C:K").from("z9")
rescue KeyError => e
  puts e.message  # => "Source not found: z9"
end

# Invalid GGN data
begin
  Sashite::Ggn.parse({ "invalid" => "data" })
rescue ArgumentError => e
  puts e.message  # => "Invalid QPI format: invalid"
end

# Safe validation
if Sashite::Ggn.valid?(data)
  ruleset = Sashite::Ggn.parse(data)
else
  puts "Invalid GGN structure"
end
```

## GGN Format Restrictions

### HAND→HAND Prohibition

Direct movements from hand to hand (`source="*"` and `destination="*"`) are **forbidden** by the specification:

```ruby
# This will raise an error
invalid_ggn = {
  "S:P" => {
    "*" => {
      "*" => [{ "must" => {}, "deny" => {} }]  # FORBIDDEN!
    }
  }
}

Sashite::Ggn.valid?(invalid_ggn)  # => false
Sashite::Ggn.parse(invalid_ggn)   # => ArgumentError
```

## Dependencies

This gem depends on other Sashité specifications:

- `sashite-cell` - Coordinate encoding (e.g., `"e4"`)
- `sashite-hand` - Reserve notation (`"*"`)
- `sashite-lcn` - Location conditions (e.g., `"empty"`, `"enemy"`)
- `sashite-qpi` - Piece identification (e.g., `"C:K"`)

## Resources

- [GGN Specification v1.0.0](https://sashite.dev/specs/ggn/1.0.0/)
- [API Documentation](https://rubydoc.info/github/sashite/ggn.rb/main)
- [GitHub Repository](https://github.com/sashite/ggn.rb)

## License

Available as open source under the [MIT License](https://opensource.org/licenses/MIT).

## About

Maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of board game cultures.
