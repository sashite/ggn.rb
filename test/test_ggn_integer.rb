require_relative '_test_helper'

describe Sashite::GGN::Integer do
  describe '.new' do
    describe 'negative' do
      before do
        @integer = Sashite::GGN::Integer.new('-42')
      end

      it 'returns the GGN as a JSON' do
        @integer.as_json.must_equal -42
      end

      it 'returns the GGN as a string' do
        @integer.to_s.must_equal '-42'
      end

      it 'raises an error' do
        -> { Sashite::GGN::Integer.new('-01') }.must_raise ArgumentError
      end
    end

    describe 'unsigned' do
      before do
        @integer = Sashite::GGN::Integer.new('42')
      end

      it 'returns the GGN as a JSON' do
        @integer.as_json.must_equal 42
      end

      it 'returns the GGN as a string' do
        @integer.to_s.must_equal '42'
      end

      it 'raises an error' do
        -> { Sashite::GGN::Integer.new('01') }.must_raise ArgumentError
      end
    end
  end
end
