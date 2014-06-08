require_relative '_test_helper'

describe Sashite::GGN::NegativeInteger do
  describe '.new' do
    before do
      @negative_integer = Sashite::GGN::NegativeInteger.new('-42')
    end

    it 'returns the GGN as a JSON' do
      @negative_integer.as_json.must_equal -42
    end

    it 'returns the GGN as a string' do
      @negative_integer.to_s.must_equal '-42'
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::NegativeInteger.new('42') }.must_raise ArgumentError
  end
end
