require_relative '_test_helper'

describe Sashite::GGN::Verb do
  describe '.new' do
    before do
      @verb = Sashite::GGN::Verb.new('shift[4,2]42/t')
    end

    it 'returns the GGN as a JSON' do
      @verb.as_json.hash.must_equal(
        {
          name: :shift,
          vector: {direction: [4,2], :"...maximum_magnitude" => 42}
        }.hash
      )
    end

    it 'returns the GGN as a string' do
      @verb.to_s.must_equal 'shift[4,2]42/t'
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::Verb.new('shift[4,2]0/t') }.must_raise ArgumentError
  end
end
