require_relative '_test_helper'

describe Sashite::GGN::Name do
  describe '.new' do
    describe 'capture' do
      before do
        @name = Sashite::GGN::Name.new('capture')
      end

      it 'returns the GGN as a JSON' do
        @name.as_json.must_equal :capture
      end

      it 'returns the GGN as a string' do
        @name.to_s.must_equal 'capture'
      end
    end

    describe 'remove' do
      before do
        @name = Sashite::GGN::Name.new('remove')
      end

      it 'returns the GGN as a JSON' do
        @name.as_json.must_equal :remove
      end

      it 'returns the GGN as a string' do
        @name.to_s.must_equal 'remove'
      end
    end

    describe 'shift' do
      before do
        @name = Sashite::GGN::Name.new('shift')
      end

      it 'returns the GGN as a JSON' do
        @name.as_json.must_equal :shift
      end

      it 'returns the GGN as a string' do
        @name.to_s.must_equal 'shift'
      end
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::Name.new('foobar') }.must_raise ArgumentError
  end
end
