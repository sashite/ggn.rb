require_relative '_test_helper'

describe Sashite::GGN::UnsignedInteger do
  describe '.new' do
    before do
      @unsigned_integer = Sashite::GGN::UnsignedInteger.new('0')
    end

    it 'returns the GGN as a JSON' do
      @unsigned_integer.as_json.must_equal 0
    end

    it 'returns the GGN as a string' do
      @unsigned_integer.to_s.must_equal '0'
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::UnsignedInteger.new('-42') }.must_raise ArgumentError
  end
end
