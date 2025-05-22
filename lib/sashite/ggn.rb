# frozen_string_literal: true

require 'json'
require 'json_schemer'
require 'pathname'

require_relative File.join("ggn", "piece")
require_relative File.join("ggn", "schema")
require_relative File.join("ggn", "validation_error")

module Sashite
  # General Gameplay Notation (GGN) module for parsing, validating, and working with
  # JSON documents that describe pseudo-legal moves in abstract strategy board games.
  #
  # GGN is a rule-agnostic format that focuses on basic movement constraints rather
  # than game-specific legality rules. It answers the fundamental question: "Can this
  # piece, currently on this square, reach that square?" while remaining neutral about
  # higher-level game rules like check, ko, repetition, or castling paths.
  #
  # = Key Features
  #
  # - **Rule-agnostic**: Works with any abstract strategy board game
  # - **Pseudo-legal** focus: Describes basic movement constraints only
  # - **JSON-based**: Structured, machine-readable format
  # - **Validation** support: Built-in schema validation
  # - **Performance** optimized: Optional validation for large datasets
  # - **Cross-game** compatible: Supports hybrid games and variants
  #
  # = Related Specifications
  #
  # GGN works alongside other Sashité specifications:
  # - **GAN** (General Actor Notation): Unique piece identifiers
  # - **FEEN** (Forsyth-Edwards Enhanced Notation): Board position representation
  # - **PMN** (Portable Move Notation): Move sequence representation
  #
  # @author Sashité <https://sashite.com/>
  # @version 1.0.0
  # @see https://sashite.dev/documents/ggn/1.0.0/ Official GGN Specification
  # @see https://sashite.dev/schemas/ggn/1.0.0/schema.json JSON Schema
  module Ggn
    class << self
      # Loads and validates a GGN JSON file from the filesystem.
      #
      # This method provides a complete pipeline for loading GGN data:
      # 1. Reads the JSON file from the filesystem with proper encoding
      # 2. Parses the JSON content into a Ruby Hash with error handling
      # 3. Optionally validates the structure against the GGN JSON Schema
      # 4. Creates and returns a Piece instance for querying moves
      #
      # @param filepath [String, Pathname] Path to the GGN JSON file to load.
      #   Supports both relative and absolute paths.
      # @param validate [Boolean] Whether to validate against GGN schema (default: true).
      #   Set to false to skip validation for improved performance on large documents.
      # @param encoding [String] File encoding to use when reading (default: 'UTF-8').
      #   Most GGN files should use UTF-8 encoding.
      #
      # @return [Piece] A Piece instance containing the parsed and validated GGN data.
      #   Use this instance to query pseudo-legal moves for specific pieces and positions.
      #
      # @raise [ValidationError] If any of the following conditions occur:
      #   - File doesn't exist or cannot be read
      #   - File contains invalid JSON syntax
      #   - File permissions prevent reading
      #   - When validation is enabled: data doesn't conform to GGN schema
      #
      # @example Loading a chess piece definition with full validation
      #   begin
      #     piece_data = Sashite::Ggn.load_file('data/chess_pieces.json')
      #     chess_king_source = piece_data.select('CHESS:K')
      #     puts "Loaded chess king movement rules successfully"
      #   rescue Sashite::Ggn::ValidationError => e
      #     puts "Failed to load chess pieces: #{e.message}"
      #   end
      #
      # @example Complete workflow with move evaluation
      #   begin
      #     piece_data = Sashite::Ggn.load_file('data/chess.json')
      #     source = piece_data.select('CHESS:K')
      #     destinations = source.from('e1')
      #     engine = destinations.to('e2')
      #
      #     board_state = { 'e1' => 'CHESS:K', 'e2' => nil }
      #     result = engine.evaluate(board_state, {}, 'CHESS')
      #     puts "King can move from e1 to e2" if result
      #   rescue Sashite::Ggn::ValidationError => e
      #     puts "Failed to process move: #{e.message}"
      #   end
      #
      # @example Loading large datasets without validation for performance
      #   begin
      #     # Skip validation for large files to improve loading performance
      #     large_dataset = Sashite::Ggn.load_file('data/all_variants.json', validate: false)
      #     puts "Loaded GGN data without validation"
      #   rescue Sashite::Ggn::ValidationError => e
      #     puts "Failed to load dataset: #{e.message}"
      #   end
      #
      # @example Handling different file encodings
      #   # Load a GGN file with specific encoding
      #   piece_data = Sashite::Ggn.load_file('legacy_data.json', encoding: 'ISO-8859-1')
      #
      # @note Performance Considerations
      #   For large GGN files (>1MB), consider setting validate: false to improve
      #   loading performance. However, this comes with the risk of processing
      #   malformed data. In production environments, validate at least once
      #   before deploying with validation disabled.
      #
      # @note Thread Safety
      #   This method is thread-safe for concurrent reads of different files.
      #   However, avoid concurrent access to the same file if it might be
      #   modified during reading.
      def load_file(filepath, validate: true, encoding: 'UTF-8')
        # Convert to Pathname for consistent file operations and better error handling
        file_path = normalize_filepath(filepath)

        # Validate file accessibility before attempting to read
        validate_file_access(file_path)

        # Parse JSON content with comprehensive error handling
        data = parse_json_file(file_path, encoding)

        # Validate against GGN schema if requested
        validate_schema(data, file_path) if validate

        # Create and return Piece instance
        Piece.new(data)
      end

      # Loads GGN data directly from a JSON string.
      #
      # This method is useful when you have GGN data as a string (e.g., from a
      # database, API response, or embedded in your application) rather than a file.
      #
      # @param json_string [String] JSON string containing GGN data
      # @param validate [Boolean] Whether to validate against GGN schema (default: true)
      #
      # @return [Piece] A Piece instance containing the parsed GGN data
      #
      # @raise [ValidationError] If the JSON is invalid or doesn't conform to GGN schema
      #
      # @example Loading GGN data from a string
      #   ggn_json = '{"CHESS:P": {"e2": {"e4": [{"require": {"e3": "empty", "e4": "empty"}, "perform": {"e2": null, "e4": "CHESS:P"}}]}}}'
      #
      #   begin
      #     piece_data = Sashite::Ggn.load_string(ggn_json)
      #     pawn_source = piece_data.select('CHESS:P')
      #     puts "Loaded pawn with move from e2 to e4"
      #   rescue Sashite::Ggn::ValidationError => e
      #     puts "Invalid GGN data: #{e.message}"
      #   end
      #
      # @example Loading from API response without validation
      #   api_response = fetch_ggn_from_api()
      #   piece_data = Sashite::Ggn.load_string(api_response.body, validate: false)
      def load_string(json_string, validate: true)
        # Parse JSON string with error handling
        begin
          data = ::JSON.parse(json_string)
        rescue ::JSON::ParserError => e
          raise ValidationError, "Invalid JSON string: #{e.message}"
        end

        # Validate against GGN schema if requested
        validate_schema(data, "<string>") if validate

        # Create and return Piece instance
        Piece.new(data)
      end

      # Loads GGN data from a Ruby Hash.
      #
      # This method is useful when you already have parsed JSON data as a Hash
      # and want to create a GGN Piece instance with optional validation.
      #
      # @param data [Hash] Ruby Hash containing GGN data structure
      # @param validate [Boolean] Whether to validate against GGN schema (default: true)
      #
      # @return [Piece] A Piece instance containing the GGN data
      #
      # @raise [ValidationError] If the data doesn't conform to GGN schema (when validation enabled)
      #
      # @example Creating from existing Hash data
      #   ggn_data = {
      #     "SHOGI:K" => {
      #       "5i" => {
      #         "4i" => [{ "require" => { "4i" => "empty" }, "perform" => { "5i" => nil, "4i" => "SHOGI:K" } }],
      #         "6i" => [{ "require" => { "6i" => "empty" }, "perform" => { "5i" => nil, "6i" => "SHOGI:K" } }]
      #       }
      #     }
      #   }
      #
      #   piece_data = Sashite::Ggn.load_hash(ggn_data)
      #   shogi_king = piece_data.select('SHOGI:K')
      def load_hash(data, validate: true)
        unless data.is_a?(Hash)
          raise ValidationError, "Expected Hash, got #{data.class}"
        end

        # Validate against GGN schema if requested
        validate_schema(data, "<hash>") if validate

        # Create and return Piece instance
        Piece.new(data)
      end

      # Validates a data structure against the GGN JSON Schema.
      #
      # This method can be used independently to validate GGN data without
      # creating a Piece instance. Useful for pre-validation or testing.
      #
      # @param data [Hash] The data structure to validate
      # @param context [String] Context information for error messages (default: "<data>")
      #
      # @return [true] If validation passes
      #
      # @raise [ValidationError] If validation fails with detailed error information
      #
      # @example Validating data before processing
      #   begin
      #     Sashite::Ggn.validate!(my_data)
      #     puts "Data is valid GGN format"
      #   rescue Sashite::Ggn::ValidationError => e
      #     puts "Validation failed: #{e.message}"
      #   end
      def validate!(data, context: "<data>")
        validate_schema(data, context)
        true
      end

      # Checks if a data structure is valid GGN format.
      #
      # @param data [Hash] The data structure to validate
      #
      # @return [Boolean] true if valid, false otherwise
      #
      # @example Checking validity without raising exceptions
      #   if Sashite::Ggn.valid?(my_data)
      #     puts "Data is valid"
      #   else
      #     puts "Data is invalid"
      #   end
      def valid?(data)
        schemer = ::JSONSchemer.schema(Schema)
        schemer.valid?(data)
      end

      # Returns detailed validation errors for a data structure.
      #
      # @param data [Hash] The data structure to validate
      #
      # @return [Array<String>] Array of validation error messages (empty if valid)
      #
      # @example Getting detailed validation errors
      #   errors = Sashite::Ggn.validation_errors(invalid_data)
      #   if errors.any?
      #     puts "Validation errors found:"
      #     errors.each { |error| puts "  - #{error}" }
      #   end
      def validation_errors(data)
        schemer = ::JSONSchemer.schema(Schema)
        schemer.validate(data).map(&:to_s)
      end

      private

      # Normalizes filepath input to Pathname instance
      def normalize_filepath(filepath)
        case filepath
        when ::Pathname
          filepath
        when String
          ::Pathname.new(filepath)
        else
          raise ValidationError, "Invalid filepath type: #{filepath.class}. Expected String or Pathname."
        end
      end

      # Validates that a file exists and is readable
      def validate_file_access(file_path)
        unless file_path.exist?
          raise ValidationError, "File not found: #{file_path}"
        end

        unless file_path.readable?
          raise ValidationError, "File not readable: #{file_path}"
        end

        unless file_path.file?
          raise ValidationError, "Path is not a file: #{file_path}"
        end
      end

      # Parses JSON file with proper error handling and encoding
      def parse_json_file(file_path, encoding)
        # Read file with specified encoding
        content = file_path.read(encoding: encoding)

        # Parse JSON content
        ::JSON.parse(content)
      rescue ::JSON::ParserError => e
        raise ValidationError, "Invalid JSON in file #{file_path}: #{e.message}"
      rescue ::Encoding::UndefinedConversionError => e
        raise ValidationError, "Encoding error in file #{file_path}: #{e.message}. Try a different encoding."
      rescue ::SystemCallError => e
        raise ValidationError, "Failed to read file #{file_path}: #{e.message}"
      end

      # Validates data against GGN schema with detailed error reporting
      def validate_schema(data, context)
        schemer = ::JSONSchemer.schema(Schema)

        return if schemer.valid?(data)

        # Collect all validation errors for comprehensive feedback
        errors = schemer.validate(data).map(&:to_s)
        error_summary = errors.size == 1 ? "1 validation error" : "#{errors.size} validation errors"

        raise ValidationError, "Invalid GGN data in #{context}: #{error_summary}: #{errors.join('; ')}"
      end
    end
  end
end
