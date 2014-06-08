require_relative '_test_helper'

describe Sashite::GGN::Boolean do
  describe '.new' do
    describe 'false' do
      before do
        @boolean = Sashite::GGN::Boolean.new('f')
      end

      it 'returns the GGN as a JSON' do
        @boolean.as_json.must_equal false
      end

      it 'returns the GGN as a string' do
        @boolean.to_s.must_equal 'f'
      end
    end

    describe 'true' do
      before do
        @boolean = Sashite::GGN::Boolean.new('t')
      end

      it 'returns the GGN as a JSON' do
        @boolean.as_json.must_equal true
      end

      it 'returns the GGN as a string' do
        @boolean.to_s.must_equal 't'
      end
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::Boolean.new('foobar') }.must_raise ArgumentError
  end
end
