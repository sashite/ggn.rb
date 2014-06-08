require_relative '_test_helper'

describe Sashite::GGN::Attacked do
  describe '.new' do
    describe 'false' do
      before do
        @attacked = Sashite::GGN::Attacked.new('f')
      end

      it 'returns the GGN as a JSON' do
        @attacked.as_json.must_equal false
      end

      it 'returns the GGN as a string' do
        @attacked.to_s.must_equal 'f'
      end
    end

    describe 'true' do
      before do
        @attacked = Sashite::GGN::Attacked.new('t')
      end

      it 'returns the GGN as a JSON' do
        @attacked.as_json.must_equal true
      end

      it 'returns the GGN as a string' do
        @attacked.to_s.must_equal 't'
      end
    end

    describe 'null' do
      before do
        @attacked = Sashite::GGN::Attacked.new('_')
      end

      it 'returns the GGN as a JSON' do
        @attacked.as_json.must_equal nil
      end

      it 'returns the GGN as a string' do
        @attacked.to_s.must_equal '_'
      end
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::Attacked.new('foobar') }.must_raise ArgumentError
  end
end
