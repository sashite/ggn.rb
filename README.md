# Ggn.rb

A Ruby implementation of the General Gameplay Notation (GGN) specification. GGN is a rule-agnostic, JSON-based format for describing pseudo-legal moves in abstract strategy board games.

[![Gem Version](https://badge.fury.io/rb/sashite-ggn.svg)](https://badge.fury.io/rb/sashite-ggn)
[![Ruby](https://github.com/sashite/ggn.rb/workflows/Ruby/badge.svg)](https://github.com/sashite/ggn.rb/actions)

## Features

- **Rule-agnostic**: Works with any abstract strategy board game
- **Pseudo-legal focus**: Describes basic movement constraints only
- **JSON-based**: Structured, machine-readable format
- **Schema validation**: Built-in JSON Schema validation
- **Performance optimized**: Efficient move generation and validation
- **Cross-game compatible**: Supports hybrid games and variants

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sashite-ggn'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install sashite-ggn
```

## Usage

### Loading GGN Data

```ruby
require "sashite-ggn"

# Load from file
piece_data = Sashite::Ggn.load_file("chess_moves.json")

# Load from JSON string
json_string = '{"CHESS:P": {"e2": {"e4": [{"require": {"e3": "empty", "e4": "empty"}, "perform": {"e2": null, "e4": "CHESS:P"}}]}}}'
piece_data = Sashite::Ggn.load_string(json_string)

# Load from Hash
ggn_hash = { "CHESS:P" => { "e2" => { "e4" => [{ "perform" => { "e2" => nil, "e4" => "CHESS:P" } }] } } }
piece_data = Sashite::Ggn.load_hash(ggn_hash)
```

### Evaluating Individual Moves

```ruby
# Check if a specific move is valid
piece_data = Sashite::Ggn.load_file("chess_moves.json")
engine = piece_data.select("CHESS:P").from("e2").to("e4")

board_state = {
  "e2" => "CHESS:P",  # White pawn on e2
  "e3" => nil,        # Empty square
  "e4" => nil         # Empty square
}

result = engine.where(board_state, {}, "CHESS")

if result
  puts "Move is valid!"
  puts "Board changes: #{result.diff}"
  # => { "e2" => nil, "e4" => "CHESS:P" }
  puts "Piece gained: #{result.gain}" # => nil (no capture)
  puts "Piece dropped: #{result.drop}" # => nil (not a drop move)
else
  puts "Move is not valid under current conditions"
end
```

### Generating All Pseudo-Legal Moves

Generate all possible pseudo-legal moves for a given position:

```ruby
piece_data = Sashite::Ggn.load_file("chess_moves.json")

board_state = {
  "e2" => "CHESS:P",
  "e7" => "chess:p",  # Opponent's pawn
  "d1" => "CHESS:Q"
}
captures = {}  # No pieces in hand

# Get all pseudo-legal moves for the current player
moves = piece_data.pseudo_legal_moves(board_state, captures, "CHESS")
# => [["e2", "e3"], ["e2", "e4"], ["d1", "d2"], ["d1", "d3"], ...]

puts "Found #{moves.length} possible moves:"
moves.each do |source, destination|
  if source == "*"
    puts "Drop piece to #{destination}"
  else
    puts "Move from #{source} to #{destination}"
  end
end
```

### Working with Piece Drops (Shogi Example)

```ruby
# Shogi allows captured pieces to be dropped back onto the board
piece_data = Sashite::Ggn.load_file("shogi_moves.json")

# Player has captured pawns available
captures = { "SHOGI:P" => 2 }

# Current board state (5th file is clear of unpromoted pawns)
board_state = {
  "5e" => nil,     # Target square is empty
  "5a" => nil, "5b" => nil, "5c" => nil, "5d" => nil,
  "5f" => nil, "5g" => nil, "5h" => nil, "5i" => nil
}

# Check all possible moves including drops
moves = piece_data.pseudo_legal_moves(board_state, captures, "SHOGI")

# Filter for drop moves only
drop_moves = moves.select { |source, _| source == "*" }
puts "Possible drops: #{drop_moves}"
# => [["*", "5e"], ["*", "5a"], ["*", "5b"], ...]
```

### Validation

```ruby
# Validate GGN data
begin
  Sashite::Ggn.validate!(my_data)
  puts "Data is valid GGN format"
rescue Sashite::Ggn::ValidationError => e
  puts "Validation failed: #{e.message}"
end

# Check validity without exceptions
if Sashite::Ggn.valid?(my_data)
  puts "Data is valid"
else
  errors = Sashite::Ggn.validation_errors(my_data)
  puts "Validation errors: #{errors.join(', ')}"
end
```

## Performance

The library includes several performance optimizations:

- **Early pruning**: Validates piece ownership and context before expensive operations
- **Shared validation logic**: Avoids code duplication through the `MoveValidator` module
- **Optional validation**: Skip schema validation for large datasets when needed
- **Efficient iteration**: Minimizes object allocations during move generation

For large GGN datasets, consider disabling validation during loading:

```ruby
# Skip validation for better performance on large files
piece_data = Sashite::Ggn.load_file("large_dataset.json", validate: false)
```

## API Reference

### Main Classes

- **`Sashite::Ggn::Piece`**: Entry point for querying piece movement rules
  - `#select(actor)`: Get movement rules for a specific piece type
  - `#pseudo_legal_moves(board_state, captures, turn)`: Generate all possible moves
- **`Sashite::Ggn::Piece::Source`**: Represents possible source positions for a piece
- **`Sashite::Ggn::Piece::Source::Destination`**: Represents possible destination squares
- **`Sashite::Ggn::Piece::Source::Destination::Engine`**: Evaluates move validity
- **`Sashite::Ggn::Piece::Source::Destination::Engine::Transition`**: Represents a valid move result

### Module Methods

- `Sashite::Ggn.load_file(filepath, validate: true)`: Load GGN data from file
- `Sashite::Ggn.load_string(json_string, validate: true)`: Load GGN data from JSON string
- `Sashite::Ggn.load_hash(data, validate: true)`: Load GGN data from Hash
- `Sashite::Ggn.valid?(data)`: Check if data is valid GGN format
- `Sashite::Ggn.validate!(data)`: Validate data, raising exception on failure
- `Sashite::Ggn.validation_errors(data)`: Get detailed validation errors

## Related Specifications

This library implements the GGN specification and works alongside other Sashité specifications:

- [GAN](https://sashite.dev/documents/gan/) (General Actor Notation): Unique piece identifiers
- [FEEN](https://sashite.dev/documents/feen/) (Forsyth-Edwards Enhanced Notation): Board position representation
- [PMN](https://sashite.dev/documents/pmn/) (Portable Move Notation): Move sequence representation

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sashite/ggn.rb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Links

- [GGN Specification](https://sashite.dev/documents/ggn/1.0.0/)
- [JSON Schema](https://sashite.dev/schemas/ggn/1.0.0/schema.json)
- [Sashité Website](https://sashite.com/)
- [API Documentation](https://rubydoc.info/github/sashite/ggn.rb/main)
