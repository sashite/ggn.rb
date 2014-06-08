require_relative '_test_helper'

describe Sashite::GGN::Ally do
  describe '.new' do
    describe 'false' do
      before do
        @ally = Sashite::GGN::Ally.new('f')
      end

      it 'returns the GGN as a JSON' do
        @ally.as_json.must_equal false
      end

      it 'returns the GGN as a string' do
        @ally.to_s.must_equal 'f'
      end
    end

    describe 'true' do
      before do
        @ally = Sashite::GGN::Ally.new('t')
      end

      it 'returns the GGN as a JSON' do
        @ally.as_json.must_equal true
      end

      it 'returns the GGN as a string' do
        @ally.to_s.must_equal 't'
      end
    end

    describe 'null' do
      before do
        @ally = Sashite::GGN::Ally.new('_')
      end

      it 'returns the GGN as a JSON' do
        @ally.as_json.must_equal nil
      end

      it 'returns the GGN as a string' do
        @ally.to_s.must_equal '_'
      end
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::Ally.new('foobar') }.must_raise ArgumentError
  end
end
