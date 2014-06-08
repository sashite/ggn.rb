require_relative '_test_helper'

describe Sashite::GGN::UnsignedIntegerExcludingZero do
  describe '.new' do
    before do
      @unsigned_integer_excluding_zero = Sashite::GGN::UnsignedIntegerExcludingZero.new('42')
    end

    it 'returns the GGN as a JSON' do
      @unsigned_integer_excluding_zero.as_json.must_equal 42
    end

    it 'returns the GGN as a string' do
      @unsigned_integer_excluding_zero.to_s.must_equal '42'
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::UnsignedIntegerExcludingZero.new('0') }.must_raise ArgumentError
  end
end
