require_relative '_test_helper'

describe Sashite::GGN::Self do
  describe '.instance' do
    before do
      @s = Sashite::GGN::Self.instance
    end

    it 'returns the GGN as a JSON' do
      @s.as_json.must_equal :self
    end

    it 'returns the GGN as a string' do
      @s.to_s.must_equal 'self'
    end
  end

  it 'is false' do
    Sashite::GGN::Self.valid?('foobar').must_equal false
  end
end
