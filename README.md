# Ggn.rb

[![Version](https://img.shields.io/github/v/tag/sashite/ggn.rb?label=Version&logo=github)](https://github.com/sashite/ggn.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/ggn.rb/main)
![Ruby](https://github.com/sashite/ggn.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/ggn.rb?label=License&logo=github)](https://github.com/sashite/ggn.rb/raw/main/LICENSE.md)

> **GGN** (General Gameplay Notation) implementation for Ruby — a pure, functional library for evaluating **movement possibilities** in abstract strategy board games.

---

## What is GGN?

GGN (General Gameplay Notation) is a rule-agnostic format for describing **pseudo-legal moves** in abstract strategy board games. GGN serves as a **movement possibility oracle**: given a movement context (piece and source location) plus a destination location, it determines if the movement is feasible under specified pre-conditions.

This gem implements the [GGN Specification v1.0.0](https://sashite.dev/specs/ggn/1.0.0/), providing complete movement possibility evaluation with environmental constraint checking.

### Core Philosophy

GGN answers the fundamental question:

> **Can this piece, currently at this location, reach that location?**

It encodes:
- **Which piece** (via QPI format)
- **From where** (source location using CELL or HAND)
- **To where** (destination location using CELL or HAND)
- **Which environmental pre-conditions** must hold (`must`)
- **Which environmental pre-conditions** must not hold (`deny`)
- **What changes occur** if executed (`diff` in STN format)

---

## Installation

```ruby
# In your Gemfile
gem "sashite-ggn"
```

Or install manually:

```sh
gem install sashite-ggn
```

---

## Dependencies

GGN builds upon foundational Sashité specifications:

```ruby
gem "sashite-cell"  # Coordinate Encoding for Layered Locations
gem "sashite-feen"  # Forsyth–Edwards Enhanced Notation
gem "sashite-hand"  # Hold And Notation Designator
gem "sashite-lcn"   # Location Condition Notation
gem "sashite-qpi"   # Qualified Piece Identifier
gem "sashite-stn"   # State Transition Notation
```

---

## Quick Start

```ruby
require "sashite/ggn"

# Parse GGN data structure
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

ruleset = Sashite::Ggn.parse(ggn_data)

# Query movement possibility through method chaining
feen = "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/c"
transitions = ruleset.select("C:P").from("e2").to("e4").where(feen)

transitions.any? # => true
```

---

## API Reference

### Module Functions

#### `Sashite::Ggn.parse(data) → Ruleset`

Parses GGN data structure into an immutable Ruleset object.

```ruby
ruleset = Sashite::Ggn.parse(ggn_data)
```

**Parameters:**
- `data` (Hash): GGN data structure conforming to specification

**Returns:** `Ruleset` — Immutable ruleset object

**Raises:** `ArgumentError` — If data structure is invalid

---

#### `Sashite::Ggn.valid?(data) → Boolean`

Validates GGN data structure against specification.

```ruby
Sashite::Ggn.valid?(ggn_data) # => true
```

**Parameters:**
- `data` (Hash): Data structure to validate

**Returns:** `Boolean` — True if valid, false otherwise

---

### `Sashite::Ggn::Ruleset` Class

Immutable container for GGN movement rules.

#### `#select(piece) → Source`

Selects movement rules for a specific piece type.

```ruby
source = ruleset.select("C:K")
```

**Parameters:**
- `piece` (String): QPI piece identifier

**Returns:** `Source` — Source selector object

**Raises:** `KeyError` — If piece not found in ruleset

---

#### `#pseudo_legal_transitions(feen) → Array<Array>`

Generates all pseudo-legal moves for the given position.

```ruby
moves = ruleset.pseudo_legal_transitions(feen)
# => [["C:P", "e2", "e4", [#<Transition...>]], ...]
```

**Parameters:**
- `feen` (String): Position in FEEN format

**Returns:** `Array<Array>` — Array of `[piece, source, destination, transitions]` tuples

---

#### `#piece?(piece) → Boolean`

Checks if ruleset contains movement rules for specified piece.

```ruby
ruleset.piece?("C:K") # => true
```

**Parameters:**
- `piece` (String): QPI piece identifier

**Returns:** `Boolean`

---

#### `#pieces → Array<String>`

Returns all piece identifiers in ruleset.

```ruby
ruleset.pieces # => ["C:K", "C:Q", "C:P", ...]
```

**Returns:** `Array<String>` — QPI piece identifiers

---

#### `#to_h → Hash`

Converts ruleset to hash representation.

```ruby
ruleset.to_h # => { "C:K" => { "e1" => { "e2" => [...] } } }
```

**Returns:** `Hash` — GGN data structure

---

### `Sashite::Ggn::Ruleset::Source` Class

Represents movement possibilities for a piece type.

#### `#from(source) → Destination`

Specifies the source location for the piece.

```ruby
destination = source.from("e1")
```

**Parameters:**
- `source` (String): Source location (CELL coordinate or HAND "*")

**Returns:** `Destination` — Destination selector object

**Raises:** `KeyError` — If source not found for this piece

---

#### `#sources → Array<String>`

Returns all valid source locations for this piece.

```ruby
source.sources # => ["e1", "d1", "*"]
```

**Returns:** `Array<String>` — Source locations

---

#### `#source?(location) → Boolean`

Checks if location is a valid source for this piece.

```ruby
source.source?("e1") # => true
```

**Parameters:**
- `location` (String): Source location

**Returns:** `Boolean`

---

### `Sashite::Ggn::Ruleset::Source::Destination` Class

Represents movement possibilities from a specific source.

#### `#to(destination) → Engine`

Specifies the destination location.

```ruby
engine = destination.to("e2")
```

**Parameters:**
- `destination` (String): Destination location (CELL coordinate or HAND "*")

**Returns:** `Engine` — Movement evaluation engine

**Raises:** `KeyError` — If destination not found from this source

---

#### `#destinations → Array<String>`

Returns all valid destinations from this source.

```ruby
destination.destinations # => ["d1", "d2", "e2", "f2", "f1"]
```

**Returns:** `Array<String>` — Destination locations

---

#### `#destination?(location) → Boolean`

Checks if location is a valid destination from this source.

```ruby
destination.destination?("e2") # => true
```

**Parameters:**
- `location` (String): Destination location

**Returns:** `Boolean`

---

### `Sashite::Ggn::Ruleset::Source::Destination::Engine` Class

Evaluates movement possibility under given position conditions.

#### `#where(feen) → Array<Transition>`

Evaluates movement against position and returns valid transitions.

```ruby
transitions = engine.where(feen)
```

**Parameters:**
- `feen` (String): Position in FEEN format

**Returns:** `Array<Sashite::Stn::Transition>` — Valid state transitions (may be empty)

---

#### `#possibilities → Array<Hash>`

Returns raw movement possibility rules.

```ruby
engine.possibilities
# => [{ "must" => {...}, "deny" => {...}, "diff" => {...} }]
```

**Returns:** `Array<Hash>` — Movement possibility specifications

---

## GGN Format

### Structure

```ruby
{
  "<qpi-piece>" => {
    "<source-location>" => {
      "<destination-location>" => [
        {
          "must" => { /* LCN format */ },
          "deny" => { /* LCN format */ },
          "diff" => { /* STN format */ }
        }
      ]
    }
  }
}
```

### Field Specifications

| Field | Type | Description |
|-------|------|-------------|
| **Piece** | String (QPI) | Piece identifier (e.g., `"C:K"`, `"s:+p"`) |
| **Source** | String (CELL/HAND) | Origin location (e.g., `"e2"`, `"*"`) |
| **Destination** | String (CELL/HAND) | Target location (e.g., `"e4"`, `"*"`) |
| **must** | Hash (LCN) | Pre-conditions that must be satisfied |
| **deny** | Hash (LCN) | Pre-conditions that must not be satisfied |
| **diff** | Hash (STN) | State transition specification |

---

## Usage Examples

### Method Chaining

```ruby
# Query specific movement
feen = "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/c"

transitions = ruleset
  .select("C:P")
  .from("e2")
  .to("e4")
  .where(feen)

transitions.size # => 1
transitions.first.board_changes # => { "e2" => nil, "e4" => "C:P" }
```

### Generate All Pseudo-Legal Moves

```ruby
feen = "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/c"

all_moves = ruleset.pseudo_legal_transitions(feen)

all_moves.each do |piece, source, destination, transitions|
  puts "#{piece}: #{source} → #{destination} (#{transitions.size} variants)"
end
```

### Existence Checks

```ruby
# Check if piece exists in ruleset
ruleset.piece?("C:K") # => true

# Check valid sources
source = ruleset.select("C:K")
source.source?("e1") # => true

# Check valid destinations
destination = source.from("e1")
destination.destination?("e2") # => true
```

### Introspection

```ruby
# List all pieces
ruleset.pieces # => ["C:K", "C:Q", "C:R", ...]

# List sources for a piece
source.sources # => ["e1", "d1", "f1", ...]

# List destinations from a source
destination.destinations # => ["d1", "d2", "e2", "f2", "f1"]

# Access raw possibilities
engine.possibilities
# => [{ "must" => {...}, "deny" => {...}, "diff" => {...} }]
```

---

## Design Properties

- **Functional**: Pure functions with no side effects
- **Immutable**: All data structures frozen and unchangeable
- **Composable**: Clean method chaining for natural query flow
- **Type-safe**: Strict validation of all inputs
- **Delegative**: Leverages CELL, FEEN, HAND, LCN, QPI, STN specifications
- **Spec-compliant**: Strictly follows GGN v1.0.0 specification

---

## Error Handling

```ruby
# Handle missing piece
begin
  source = ruleset.select("INVALID:X")
rescue KeyError => e
  puts "Piece not found: #{e.message}"
end

# Handle missing source
begin
  destination = source.from("z9")
rescue KeyError => e
  puts "Source not found: #{e.message}"
end

# Handle missing destination
begin
  engine = destination.to("z9")
rescue KeyError => e
  puts "Destination not found: #{e.message}"
end

# Safe validation before parsing
if Sashite::Ggn.valid?(data)
  ruleset = Sashite::Ggn.parse(data)
else
  puts "Invalid GGN structure"
end
```

---

## Related Specifications

- [GGN v1.0.0](https://sashite.dev/specs/ggn/1.0.0/) — General Gameplay Notation specification
- [CELL v1.0.0](https://sashite.dev/specs/cell/1.0.0/) — Coordinate encoding
- [FEEN v1.0.0](https://sashite.dev/specs/feen/1.0.0/) — Position notation
- [HAND v1.0.0](https://sashite.dev/specs/hand/1.0.0/) — Reserve notation
- [LCN v1.0.0](https://sashite.dev/specs/lcn/1.0.0/) — Location conditions
- [QPI v1.0.0](https://sashite.dev/specs/qpi/1.0.0/) — Piece identification
- [STN v1.0.0](https://sashite.dev/specs/stn/1.0.0/) — State transitions

---

## License

Available as open source under the [MIT License](https://opensource.org/licenses/MIT).

---

## About

Maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of board game cultures.
