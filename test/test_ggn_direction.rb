require_relative '_test_helper'

describe Sashite::GGN::Direction do
  describe '.new' do
    before do
      @direction = Sashite::GGN::Direction.new('0,1,2,3,4')
    end

    it 'returns the GGN as a JSON' do
      @direction.as_json.must_equal [ 0, 1, 2, 3, 4 ]
    end

    it 'returns the GGN as a string' do
      @direction.to_s.must_equal '0,1,2,3,4'
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::Direction.new('-01') }.must_raise ArgumentError
  end
end
