require_relative '_test_helper'

describe Sashite::GGN::PreviousMovesCounter do
  describe '.new' do
    describe 'null' do
      before do
        @previous_moves_counter = Sashite::GGN::PreviousMovesCounter.new('_')
      end

      it 'returns the GGN as a JSON' do
        @previous_moves_counter.as_json.must_equal nil
      end

      it 'returns the GGN as a string' do
        @previous_moves_counter.to_s.must_equal '_'
      end

      it 'raises an error' do
        -> { Sashite::GGN::PreviousMovesCounter.new('foobar') }.must_raise ArgumentError
      end
    end

    describe 'unsigned integer' do
      before do
        @previous_moves_counter = Sashite::GGN::PreviousMovesCounter.new('42')
      end

      it 'returns the GGN as a JSON' do
        @previous_moves_counter.as_json.must_equal 42
      end

      it 'returns the GGN as a string' do
        @previous_moves_counter.to_s.must_equal '42'
      end

      it 'raises an error' do
        -> { Sashite::GGN::PreviousMovesCounter.new('-42') }.must_raise ArgumentError
      end
    end
  end
end
