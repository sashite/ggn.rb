require_relative '_test_helper'

describe Sashite::GGN::Null do
  describe '.instance' do
    before do
      @null = Sashite::GGN::Null.instance
    end

    it 'returns the GGN as a JSON' do
      @null.as_json.must_be_nil
    end

    it 'returns the GGN as a string' do
      @null.to_s.must_equal '_'
    end
  end

  it 'is false' do
    Sashite::GGN::Null.valid?('foobar').must_equal false
  end
end
