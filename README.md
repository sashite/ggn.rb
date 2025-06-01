# Ggn.rb

[![Gem Version](https://badge.fury.io/rb/sashite-ggn.svg)](https://badge.fury.io/rb/sashite-ggn)
[![Ruby](https://github.com/sashite/ggn.rb/workflows/Ruby/badge.svg)](https://github.com/sashite/ggn.rb/actions)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/ggn.rb/main)
[![License](https://img.shields.io/github/license/sashite/ggn.rb?label=License&logo=github)](https://github.com/sashite/ggn.rb/raw/main/LICENSE.md)

> A Ruby library for [GGN (General Gameplay Notation)](https://sashite.dev/documents/ggn/1.0.0/) - a rule-agnostic format for describing pseudo-legal moves in abstract strategy board games.

## What is GGN?

GGN is like having a universal "move library" that works across different board games. Think of it as a detailed catalog that answers: **"Can this piece, currently on this square, reach that square?"** - without worrying about specific game rules like check, ko, or castling rights.

**Key Features:**

- **Rule-agnostic**: Works with Chess, Shōgi, Xiangqi, and custom variants
- **Board-focused**: Describes only board transformations (no hand management)
- **Pseudo-legal**: Basic movement constraints, not full game legality
- **JSON-based**: Structured, machine-readable format
- **Performance-optimized**: Pre-computed move libraries for fast evaluation
- **Cross-game compatible**: Supports hybrid games mixing different variants
- **Flexible validation**: Choose between safety and performance

## Installation

Add this line to your application's Gemfile:

```ruby
gem "sashite-ggn"
```

Or install it directly:

```bash
gem install sashite-ggn
```

## Quick Start

### Basic Example: Loading Move Rules

```ruby
require "sashite/ggn"

# Load GGN data from file (with full validation by default)
ruleset = Sashite::Ggn.load_file("chess_moves.json")

# Query specific piece movement rules
pawn_source = ruleset.select("CHESS:P")
destinations = pawn_source.from("e2")
engine = destinations.to("e4")

# Check if move is valid given current board state
board_state = {
  "e2" => "CHESS:P",  # White pawn on e2
  "e3" => nil,        # Empty square
  "e4" => nil         # Empty square
}

transitions = engine.where(board_state, "CHESS")

if transitions.any?
  transition = transitions.first
  puts "Move is valid!"
  puts "Board changes: #{transition.diff}"
  # => { "e2" => nil, "e4" => "CHESS:P" }
else
  puts "Move blocked or invalid"
end
```

### Basic Example: Loading from JSON String

```ruby
# Simple pawn double move rule
ggn_json = {
  "CHESS:P" => {
    "e2" => {
      "e4" => [{
        "require" => { "e3" => "empty", "e4" => "empty" },
        "perform" => { "e2" => nil, "e4" => "CHESS:P" }
      }]
    }
  }
}

ruleset = Sashite::Ggn.load_hash(ggn_json)
puts "Loaded pawn movement rules!"
```

## Validation System

Ggn.rb offers **flexible validation** with two modes:

### Full Validation (Default)
```ruby
# All validations enabled (recommended for development/safety)
ruleset = Sashite::Ggn.load_file("moves.json")
# ✓ JSON Schema validation
# ✓ Logical contradiction detection
# ✓ Implicit requirement duplication detection
```

### Performance Mode
```ruby
# All validations disabled (maximum performance)
ruleset = Sashite::Ggn.load_file("moves.json", validate: false)
# ✗ No validation (use with pre-validated data)
```

### Validation Levels

| Validation Type | Purpose | When Enabled |
|----------------|---------|--------------|
| **JSON Schema** | Ensures GGN format compliance | `validate: true` in load methods |
| **Logical Contradictions** | Detects impossible require/prevent conditions | `validate: true` in Ruleset.new |
| **Implicit Duplications** | Prevents redundant requirements | `validate: true` in Ruleset.new |

```ruby
# Selective validation for specific use cases
if Sashite::Ggn.valid?(data)  # Quick schema check only
  ruleset = Sashite::Ggn::Ruleset.new(data, validate: false)  # Skip internal validations
end
```

## Understanding GGN Format

A GGN document has this structure:

```json
{
  "<piece_identifier>": {
    "<source_square>": {
      "<destination_square>": [
        {
          "require": { "<square>": "<required_state>" },
          "prevent": { "<square>": "<forbidden_state>" },
          "perform": { "<square>": "<new_state_or_null>" }
        }
      ]
    }
  }
}
```

### Core Concepts

- **Piece Identifier**: Uses GAN format like `"CHESS:P"` or `"shogi:+p"`
- **require**: Conditions that MUST be true (logical AND)
- **prevent**: Conditions that MUST NOT be true (logical OR)
- **perform**: Board changes after the move (REQUIRED)

### Occupation States

| State | Meaning |
|-------|---------|
| `"empty"` | Square must be empty |
| `"enemy"` | Square must contain an opposing piece |
| `"CHESS:K"` | Square must contain exactly this piece |

## Complete API Reference

### Core Loading Methods

#### `Sashite::Ggn.load_file(filepath, validate: true)`

Loads and validates a GGN JSON file.

**Parameters:**
- `filepath` [String] - Path to GGN JSON file
- `validate` [Boolean] - Whether to perform all validations (default: true)

**Returns:** Ruleset instance

**Example:**

```ruby
# Load with full validation (recommended)
ruleset = Sashite::Ggn.load_file("moves.json")

# Load without validation (faster for large files)
ruleset = Sashite::Ggn.load_file("large_moves.json", validate: false)
```

#### `Sashite::Ggn.load_string(json_string, validate: true)`

Loads GGN data from a JSON string.

**Example:**

```ruby
json = '{"CHESS:K": {"e1": {"e2": [{"perform": {"e1": null, "e2": "CHESS:K"}}]}}}'
ruleset = Sashite::Ggn.load_string(json)
```

#### `Sashite::Ggn.load_hash(data, validate: true)`

Creates a ruleset from existing Hash data.

### Navigation Methods

#### `ruleset.select(piece_identifier)`

Retrieves movement rules for a specific piece type.

**Returns:** Source instance

**Example:**

```ruby
# Get chess king movement rules
king_source = ruleset.select("CHESS:K")

# Get promoted shogi pawn rules
promoted_pawn = ruleset.select("SHOGI:+P")
```

#### `source.from(origin_square)`

Gets possible destinations from a source position.

**Returns:** Destination instance

#### `destination.to(target_square)`

Creates an engine for evaluating a specific move.

**Returns:** Engine instance

#### `engine.where(board_state, active_game)`

Evaluates move validity and returns transitions.

**Parameters:**
- `board_state` [Hash] - Current board: `{"square" => "piece_or_nil"}`
- `active_game` [String] - Current player's game identifier (e.g., "CHESS", "shogi")

**Returns:** Array of Transition objects

**Example:**

```ruby
board = { "e1" => "CHESS:K", "e2" => nil, "f1" => nil }
transitions = engine.where(board, "CHESS")

transitions.each do |transition|
  puts "Move result: #{transition.diff}"
end
```

#### `ruleset.pseudo_legal_transitions(board_state, active_game)`

Generates ALL possible moves for the current position.

**Returns:** Array of `[actor, origin, target, transitions]`

**Example:**

```ruby
board = { "e2" => "CHESS:P", "e1" => "CHESS:K" }
all_moves = ruleset.pseudo_legal_transitions(board, "CHESS")

all_moves.each do |actor, origin, target, transitions|
  puts "#{actor}: #{origin} → #{target} (#{transitions.size} variants)"
end
```

## Working with Different Move Types

### Simple Piece Movement

```ruby
# King moves one square in any direction
{
  "CHESS:K" => {
    "e1" => {
      "e2" => [{ "require" => { "e2" => "empty" }, "perform" => { "e1" => nil, "e2" => "CHESS:K" } }],
      "f1" => [{ "require" => { "f1" => "empty" }, "perform" => { "e1" => nil, "f1" => "CHESS:K" } }],
      "d1" => [{ "require" => { "d1" => "empty" }, "perform" => { "e1" => nil, "d1" => "CHESS:K" } }]
    }
  }
}
```

### Capturing Moves

```ruby
# Pawn captures diagonally
{
  "CHESS:P" => {
    "e4" => {
      "f5" => [{
        "require" => { "f5" => "enemy" },
        "perform" => { "e4" => nil, "f5" => "CHESS:P" }
      }]
    }
  }
}
```

### Sliding Pieces

```ruby
# Rook moves along empty file
{
  "CHESS:R" => {
    "a1" => {
      "a3" => [{
        "require" => { "a2" => "empty", "a3" => "empty" },
        "perform" => { "a1" => nil, "a3" => "CHESS:R" }
      }]
    }
  }
}
```

### Multiple Promotion Choices

```ruby
# Chess pawn promotion offers 4 choices
{
  "CHESS:P" => {
    "e7" => {
      "e8" => [
        { "require" => { "e8" => "empty" }, "perform" => { "e7" => nil, "e8" => "CHESS:Q" } },
        { "require" => { "e8" => "empty" }, "perform" => { "e7" => nil, "e8" => "CHESS:R" } },
        { "require" => { "e8" => "empty" }, "perform" => { "e7" => nil, "e8" => "CHESS:B" } },
        { "require" => { "e8" => "empty" }, "perform" => { "e7" => nil, "e8" => "CHESS:N" } }
      ]
    }
  }
}

# Evaluate promotion
board = { "e7" => "CHESS:P", "e8" => nil }
transitions = engine.where(board, "CHESS")

puts "#{transitions.size} promotion choices available"
transitions.each_with_index do |t, i|
  piece = t.diff["e8"]
  puts "Choice #{i + 1}: Promote to #{piece}"
end
```

### Complex Multi-Square Moves

```ruby
# Castling involves both king and rook
{
  "CHESS:K" => {
    "e1" => {
      "g1" => [{
        "require" => { "f1" => "empty", "g1" => "empty", "h1" => "CHESS:R" },
        "perform" => { "e1" => nil, "f1" => "CHESS:R", "g1" => "CHESS:K", "h1" => nil }
      }]
    }
  }
}

# Evaluate castling
board = { "e1" => "CHESS:K", "f1" => nil, "g1" => nil, "h1" => "CHESS:R" }
transitions = engine.where(board, "CHESS")

if transitions.any?
  puts "Castling is possible!"
  puts "Final position: #{transitions.first.diff}"
end
```

### En Passant Capture

```ruby
# Pawn captures en passant (removes piece from different square)
{
  "CHESS:P" => {
    "d5" => {
      "e6" => [{
        "require" => { "e5" => "chess:p", "e6" => "empty" },
        "perform" => { "d5" => nil, "e5" => nil, "e6" => "CHESS:P" }
      }]
    }
  }
}
```

### Conditional Moves with Prevention

```ruby
# Move that's blocked by certain pieces
{
  "GAME:B" => {
    "c1" => {
      "f4" => [{
        "require" => { "d2" => "empty", "e3" => "empty" },
        "prevent" => { "g5" => "GAME:K", "h6" => "GAME:Q" },  # Blocked if these pieces present
        "perform" => { "c1" => nil, "f4" => "GAME:B" }
      }]
    }
  }
}
```

## Validation and Error Handling

### Schema Validation

```ruby
# Validate GGN data structure
if Sashite::Ggn.valid?(ggn_data)
  puts "Valid GGN format"
else
  errors = Sashite::Ggn.validation_errors(ggn_data)
  puts "Validation errors: #{errors}"
end

# Validate and raise exception on failure
begin
  Sashite::Ggn.validate!(ggn_data)
  puts "Data is valid"
rescue Sashite::Ggn::ValidationError => e
  puts "Invalid: #{e.message}"
end
```

### Safe Loading for User Input

```ruby
def load_user_ggn_file(filepath, environment = :development)
  validate = (environment == :development)  # Full validation in dev only

  ruleset = Sashite::Ggn.load_file(filepath, validate: validate)
  puts "Successfully loaded #{filepath}"
  ruleset
rescue Sashite::Ggn::ValidationError => e
  puts "Failed to load #{filepath}: #{e.message}"
  nil
end
```

### Logical Validation

The library automatically detects logical inconsistencies when `validate: true`:

```ruby
# ❌ This will raise ValidationError - logical contradiction
invalid_data = {
  "CHESS:B" => {
    "c1" => {
      "f4" => [{
        "require" => { "d2" => "empty" },
        "prevent" => { "d2" => "empty" },  # Contradiction!
        "perform" => { "c1" => nil, "f4" => "CHESS:B" }
      }]
    }
  }
}

# ❌ This will raise ValidationError - redundant implicit requirement
invalid_data = {
  "CHESS:K" => {
    "e1" => {
      "e2" => [{
        "require" => { "e1" => "CHESS:K" },  # Redundant!
        "perform" => { "e1" => nil, "e2" => "CHESS:K" }
      }]
    }
  }
}
```

## Working with Different Games

### Chess Integration

```ruby
# Load chess move rules
chess_rules = Sashite::Ggn.load_file("chess.json")

# Evaluate specific chess position
board = {
  "e1" => "CHESS:K", "d1" => "CHESS:Q", "a1" => "CHESS:R", "h1" => "CHESS:R",
  "e2" => "CHESS:P", "d2" => "CHESS:P", "f2" => "CHESS:P", "g2" => "CHESS:P"
}

all_moves = chess_rules.pseudo_legal_transitions(board, "CHESS")
puts "White has #{all_moves.size} possible moves"
```

### Shōgi Integration

```ruby
# Load shogi move rules
shogi_rules = Sashite::Ggn.load_file("shogi.json")

# Query promoted piece movement
promoted_pawn = shogi_rules.select("SHOGI:+P")
destinations = promoted_pawn.from("5e")
```

### Cross-Game Scenarios

```ruby
# Hybrid game with pieces from different variants
mixed_data = {
  "CHESS:K" => { /* chess king rules */ },
  "SHOGI:G" => { /* shogi gold rules */ },
  "XIANGQI:E" => { /* xiangqi elephant rules */ }
}

ruleset = Sashite::Ggn.load_hash(mixed_data)

# All uppercase pieces controlled by same player
board = { "e1" => "CHESS:K", "f1" => "SHOGI:G", "g1" => "XIANGQI:E" }
moves = ruleset.pseudo_legal_transitions(board, "MIXED")
```

## Advanced Features

### Performance Optimization

```ruby
# Choose validation level based on your needs
def load_ggn_optimized(filepath, trusted_source: false)
  if trusted_source
    # Maximum performance for pre-validated data
    Sashite::Ggn.load_file(filepath, validate: false)
  else
    # Full validation for safety
    Sashite::Ggn.load_file(filepath, validate: true)
  end
end

# Pre-validate once, then use fast loading
if Sashite::Ggn.valid?(data)
  fast_ruleset = Sashite::Ggn.load_hash(data, validate: false)
else
  puts "Invalid data detected"
end
```

### Custom Game Development

```ruby
# Define movement rules for custom game pieces
custom_ggn = {
  "MYGAME:X" => {
    "a1" => {
      "c3" => [{
        "require" => { "b2" => "empty" },
        "perform" => { "a1" => nil, "c3" => "MYGAME:X" }
      }]
    }
  }
}

ruleset = Sashite::Ggn.load_hash(custom_ggn)
```

### Database Integration

```ruby
class MoveDatabase
  def initialize
    @rulesets = {}
  end

  def load_game_rules(game_name, filepath, validate: true)
    @rulesets[game_name] = Sashite::Ggn.load_file(filepath, validate: validate)
  rescue Sashite::Ggn::ValidationError => e
    warn "Failed to load #{game_name}: #{e.message}"
  end

  def evaluate_position(game_name, board_state, active_player)
    ruleset = @rulesets[game_name]
    return [] unless ruleset

    ruleset.pseudo_legal_transitions(board_state, active_player)
  end
end

# Usage
db = MoveDatabase.new
db.load_game_rules("chess", "rules/chess.json", validate: true)   # Full validation
db.load_game_rules("shogi", "rules/shogi.json", validate: false)  # Fast loading

moves = db.evaluate_position("chess", board_state, "CHESS")
```

## Real-World Examples

### Game Engine Integration

```ruby
class GameEngine
  def initialize(ruleset)
    @ruleset = ruleset
  end

  def legal_moves(board_state, active_player)
    # Get all pseudo-legal moves from GGN
    pseudo_legal = @ruleset.pseudo_legal_transitions(board_state, active_player)

    # Filter for actual legality (check, etc.) - game-specific logic
    pseudo_legal.select { |move| actually_legal?(move, board_state) }
  end

  def make_move(actor, origin, target, board_state, active_player)
    engine = @ruleset.select(actor).from(origin).to(target)
    transitions = engine.where(board_state, active_player)

    return nil if transitions.empty?

    # Apply the first valid transition (or let user choose for promotions)
    transition = transitions.first
    apply_transition(board_state, transition.diff)
  end

  private

  def apply_transition(board_state, diff)
    new_board = board_state.dup
    diff.each { |square, piece| new_board[square] = piece }
    new_board
  end
end
```

### Move Validation Service

```ruby
class MoveValidator
  def initialize(ggn_filepath, validate_ggn: true)
    @ruleset = Sashite::Ggn.load_file(ggn_filepath, validate: validate_ggn)
  end

  def validate_move(piece, from, to, board, player)
    begin
      engine = @ruleset.select(piece).from(from).to(to)
      transitions = engine.where(board, player)

      {
        valid: transitions.any?,
        transitions: transitions,
        error: nil
      }
    rescue KeyError
      { valid: false, transitions: [], error: "Unknown piece or position" }
    rescue => e
      { valid: false, transitions: [], error: e.message }
    end
  end
end

# Usage
validator = MoveValidator.new("chess.json", validate_ggn: true)
result = validator.validate_move("CHESS:P", "e2", "e4", board_state, "CHESS")

if result[:valid]
  puts "Move is valid"
  puts "#{result[:transitions].size} possible outcomes"
else
  puts "Invalid move: #{result[:error]}"
end
```

## Best Practices

### 1. Choose Validation Level Appropriately

```ruby
# Development: Always validate for safety
ruleset = Sashite::Ggn.load_file(filepath, validate: true)

# Production with trusted data: Optimize for performance
ruleset = Sashite::Ggn.load_file(filepath, validate: false)

# Production with untrusted data: Validate first, then cache
def load_rules_safely(filepath)
  # Validate once during deployment
  Sashite::Ggn.validate!(JSON.parse(File.read(filepath)))

  # Then use fast loading in runtime
  Sashite::Ggn.load_file(filepath, validate: false)
rescue Sashite::Ggn::ValidationError => e
  puts "GGN validation failed: #{e.message}"
  exit(1)
end
```

### 2. Handle Multiple Variants Gracefully

```ruby
# Good: Let users choose promotion pieces
def handle_promotion(transitions)
  return transitions.first if transitions.size == 1

  puts "Choose promotion:"
  transitions.each_with_index do |t, i|
    piece = t.diff.values.find { |v| v&.include?(":") }
    puts "#{i + 1}. #{piece}"
  end

  choice = gets.to_i - 1
  transitions[choice] if choice.between?(0, transitions.size - 1)
end
```

### 3. Use Consistent Game Identifiers

```ruby
# Good: Clear, consistent naming
GAME_IDENTIFIERS = {
  chess_white: "CHESS",
  chess_black: "chess",
  shogi_sente: "SHOGI",
  shogi_gote: "shogi"
}.freeze
```

### 4. Error Handling Strategy

```ruby
# Good: Comprehensive error handling
begin
  ruleset = Sashite::Ggn.load_file(filepath, validate: validate_level)
rescue Sashite::Ggn::ValidationError => e
  logger.error "GGN validation failed: #{e.message}"
  raise GameLoadError, "Invalid move rules file"
rescue Errno::ENOENT
  logger.error "Move rules file not found: #{filepath}"
  raise GameLoadError, "Move rules file missing"
end
```

## Compatibility and Performance

- **Ruby Version**: >= 3.2.0
- **Thread Safety**: All operations are thread-safe
- **Memory**: Efficient hash-based lookup
- **Performance**: O(1) piece selection, O(n) move generation
- **Validation**: Flexible validation system for different use cases

## Related Sashité Specifications

GGN works alongside other Sashité notation standards:

- [GAN v1.0.0](https://sashite.dev/documents/gan/1.0.0/) - General Actor Notation for piece identifiers
- [FEEN v1.0.0](https://sashite.dev/documents/feen/1.0.0/) - Board position representation
- [PNN v1.0.0](https://sashite.dev/documents/pnn/1.0.0/) - Piece notation with state modifiers
- [PMN v1.0.0](https://sashite.dev/documents/pmn/1.0.0/) - Portable move notation for game sequences

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sashite/ggn.rb.

## License

The [gem](https://rubygems.org/gems/sashite-ggn) is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This project is maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of Chinese, Japanese, and Western chess cultures.
