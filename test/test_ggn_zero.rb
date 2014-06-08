require_relative '_test_helper'

describe Sashite::GGN::Zero do
  describe '.instance' do
    before do
      @s = Sashite::GGN::Zero.instance
    end

    it 'returns the GGN as a JSON' do
      @s.as_json.must_equal 0
    end

    it 'returns the GGN as a string' do
      @s.to_s.must_equal '0'
    end
  end

  it 'is false' do
    Sashite::GGN::Zero.valid?('foobar').must_equal false
  end
end
