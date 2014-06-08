require_relative '_test_helper'

describe Sashite::GGN::Digit do
  describe '.new' do
    before do
      @integer = Sashite::GGN::Digit.new('8')
    end

    it 'returns the GGN as a JSON' do
      @integer.as_json.must_equal 8
    end

    it 'returns the GGN as a string' do
      @integer.to_s.must_equal '8'
    end

    it 'raises an error' do
      -> { Sashite::GGN::Digit.new('-8') }.must_raise ArgumentError
    end
  end
end
