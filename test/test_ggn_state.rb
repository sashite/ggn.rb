require_relative '_test_helper'

describe Sashite::GGN::State do
  describe '.new' do
    describe 'a state' do
      before do
        @state = Sashite::GGN::State.new('t&_')
      end

      it 'returns the GGN as a JSON' do
        @state.as_json.hash.must_equal(
          {
            :"...last_moved_actor?" => true,
            :"...previous_moves_counter" => nil
          }.hash
        )
      end

      it 'returns the GGN as a string' do
        @state.to_s.must_equal 't&_'
      end
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::State.new('foobar') }.must_raise ArgumentError
  end
end
