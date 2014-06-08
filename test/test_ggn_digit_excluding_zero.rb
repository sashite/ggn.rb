require_relative '_test_helper'

describe Sashite::GGN::DigitExcludingZero do
  describe '.new' do
    before do
      @digit_excluding_zero = Sashite::GGN::DigitExcludingZero.new('8')
    end

    it 'returns the GGN as a JSON' do
      @digit_excluding_zero.as_json.must_equal 8
    end

    it 'returns the GGN as a string' do
      @digit_excluding_zero.to_s.must_equal '8'
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::DigitExcludingZero.new( '0') }.must_raise ArgumentError
    -> { Sashite::GGN::DigitExcludingZero.new('42') }.must_raise ArgumentError
  end
end
