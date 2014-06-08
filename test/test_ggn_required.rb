require_relative '_test_helper'

describe Sashite::GGN::Required do
  describe '.new' do
    describe 'false' do
      before do
        @required = Sashite::GGN::Required.new('f')
      end

      it 'returns the GGN as a JSON' do
        @required.as_json.must_equal false
      end

      it 'returns the GGN as a string' do
        @required.to_s.must_equal 'f'
      end
    end

    describe 'true' do
      before do
        @required = Sashite::GGN::Required.new('t')
      end

      it 'returns the GGN as a JSON' do
        @required.as_json.must_equal true
      end

      it 'returns the GGN as a string' do
        @required.to_s.must_equal 't'
      end
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::Required.new('foobar') }.must_raise ArgumentError
  end
end
