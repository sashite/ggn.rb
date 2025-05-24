# frozen_string_literal: true

require_relative "move_validator"
require_relative File.join("piece", "source")

module Sashite
  module Ggn
    # Represents a collection of piece definitions from a GGN document.
    #
    # A Piece instance contains all the pseudo-legal move definitions for
    # various game pieces, organized by their GAN (General Actor Notation)
    # identifiers. This class provides the entry point for querying specific
    # piece movement rules.
    #
    # @example Basic usage
    #   piece_data = Sashite::Ggn.load_file('chess.json')
    #   chess_king = piece_data.select('CHESS:K')
    #   shogi_pawn = piece_data.select('SHOGI:P')
    #
    # @example Complete workflow
    #   piece_data = Sashite::Ggn.load_file('game_moves.json')
    #
    #   # Query specific piece moves
    #   begin
    #     king_source = piece_data.select('CHESS:K')
    #     puts "Found chess king movement rules"
    #   rescue KeyError
    #     puts "Chess king not found in this dataset"
    #   end
    #
    # @see https://sashite.dev/documents/gan/ GAN Specification
    class Piece
      include MoveValidator

      # Creates a new Piece instance from GGN data.
      #
      # @param data [Hash] The parsed GGN JSON data structure, where keys are
      #   GAN identifiers and values contain the movement definitions.
      #
      # @raise [ArgumentError] If data is not a Hash
      def initialize(data)
        raise ::ArgumentError, "Expected Hash, got #{data.class}" unless data.is_a?(::Hash)

        @data = data

        freeze
      end

      # Retrieves movement rules for a specific piece type.
      #
      # @param actor [String] The GAN identifier for the piece type
      #   (e.g., 'CHESS:K', 'SHOGI:P', 'chess:q'). Must match exactly
      #   including case sensitivity.
      #
      # @return [Source] A Source instance containing all movement rules
      #   for this piece type from different board positions.
      #
      # @raise [KeyError] If the actor is not found in the GGN data
      #
      # @example Fetching chess king moves
      #   source = piece_data.select('CHESS:K')
      #   destinations = source.from('e1')
      #   engine = destinations.to('e2')
      #
      # @example Handling missing pieces
      #   begin
      #     moves = piece_data.select('NONEXISTENT:X')
      #   rescue KeyError => e
      #     puts "Piece not found: #{e.message}"
      #   end
      #
      # @note The actor format must follow GAN specification:
      #   GAME:piece (e.g., CHESS:K, shogi:p, XIANGQI:E)
      def select(actor)
        data = @data.fetch(actor)
        Source.new(data, actor:)
      end

      # Returns all pseudo-legal moves possible for the given position.
      #
      # This method traverses all actors defined in the GGN data,
      # tests each possible movement and returns those that are valid
      # according to the pseudo-legal constraints defined. Uses performance
      # optimizations to prune invalid branches early.
      #
      # @param board_state [Hash] Current board state mapping square labels
      #   to piece identifiers (nil for empty squares)
      # @param captures [Hash] Available pieces in hand for drops
      # @param turn [String] Current player's game identifier (e.g., 'CHESS', 'shogi')
      #
      # @return [Array<Array(String, String)>] List of moves as
      #   [source_square, destination_square]. For drops, source_square is "*".
      #
      # @raise [ArgumentError] If any parameter is invalid or malformed
      #
      # @example Getting all possible moves
      #   board_state = { 'e2' => 'CHESS:P', 'e3' => nil, 'e4' => nil }
      #   captures = {}
      #   moves = piece_data.pseudo_legal_moves(board_state, captures, 'CHESS')
      #   # => [['e2', 'e3'], ['e2', 'e4']]
      #
      # @example With drops (Shogi)
      #   board_state = { '5e' => nil }
      #   captures = { 'SHOGI:P' => 1 }
      #   moves = piece_data.pseudo_legal_moves(board_state, captures, 'SHOGI')
      #   # => [['*', '5e']]
      #
      # @example Empty result for invalid position
      #   board_state = { 'e2' => 'CHESS:P', 'e3' => 'CHESS:N', 'e4' => nil }
      #   moves = piece_data.pseudo_legal_moves(board_state, {}, 'CHESS')
      #   # => [['e2', 'e3']] (only single square move possible)
      def pseudo_legal_moves(board_state, captures, turn)
        validate_pseudo_legal_parameters!(board_state, captures, turn)

        moves = []

        @data.each do |actor, source_data|
          # Performance optimization: check if piece belongs to current player first
          next unless piece_belongs_to_current_player?(actor, turn)

          source = Source.new(source_data, actor: actor)

          source_data.each do |origin, destination_data|
            # Performance optimization: check pre-conditions based on movement type
            if origin == DROP_ORIGIN
              next unless piece_available_in_hand?(actor, captures)
            else
              next unless piece_on_board_at_origin?(actor, origin, board_state)
            end

            destination = Source::Destination.new(destination_data, actor: actor, origin: origin)

            destination_data.each_key do |target|
              engine = Source::Destination::Engine.new(*destination_data[target], actor: actor, origin: origin, target: target)

              if engine.where(board_state, captures, turn)
                moves << [origin, target]
              end
            end
          end
        end

        moves
      end

      private

      # Validates parameters for pseudo_legal_moves method.
      #
      # @param board_state [Object] Should be a Hash
      # @param captures [Object] Should be a Hash
      # @param turn [Object] Should be a String
      #
      # @raise [ArgumentError] If any parameter is invalid
      def validate_pseudo_legal_parameters!(board_state, captures, turn)
        unless board_state.is_a?(::Hash)
          raise ::ArgumentError, "board_state must be a Hash, got #{board_state.class}"
        end

        unless captures.is_a?(::Hash)
          raise ::ArgumentError, "captures must be a Hash, got #{captures.class}"
        end

        unless turn.is_a?(::String)
          raise ::ArgumentError, "turn must be a String, got #{turn.class}"
        end

        if turn.empty?
          raise ::ArgumentError, "turn cannot be empty"
        end
      end
    end
  end
end
