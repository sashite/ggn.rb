require_relative '_test_helper'

describe Sashite::GGN::MaximumMagnitude do
  describe '.new' do
    describe 'null' do
      before do
        @maximum_magnitude = Sashite::GGN::MaximumMagnitude.new('_')
      end

      it 'returns the GGN as a JSON' do
        @maximum_magnitude.as_json.must_equal nil
      end

      it 'returns the GGN as a string' do
        @maximum_magnitude.to_s.must_equal '_'
      end
    end

    describe 'unsigned integer' do
      before do
        @maximum_magnitude = Sashite::GGN::MaximumMagnitude.new('42')
      end

      it 'returns the GGN as a JSON' do
        @maximum_magnitude.as_json.must_equal 42
      end

      it 'returns the GGN as a string' do
        @maximum_magnitude.to_s.must_equal '42'
      end
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::MaximumMagnitude.new('0') }.must_raise ArgumentError
  end
end
