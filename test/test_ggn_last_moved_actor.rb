require_relative '_test_helper'

describe Sashite::GGN::LastMovedActor do
  describe '.new' do
    describe 'false' do
      before do
        @last_moved_actor = Sashite::GGN::LastMovedActor.new('f')
      end

      it 'returns the GGN as a JSON' do
        @last_moved_actor.as_json.must_equal false
      end

      it 'returns the GGN as a string' do
        @last_moved_actor.to_s.must_equal 'f'
      end
    end

    describe 'true' do
      before do
        @last_moved_actor = Sashite::GGN::LastMovedActor.new('t')
      end

      it 'returns the GGN as a JSON' do
        @last_moved_actor.as_json.must_equal true
      end

      it 'returns the GGN as a string' do
        @last_moved_actor.to_s.must_equal 't'
      end
    end

    describe 'null' do
      before do
        @last_moved_actor = Sashite::GGN::LastMovedActor.new('_')
      end

      it 'returns the GGN as a JSON' do
        @last_moved_actor.as_json.must_equal nil
      end

      it 'returns the GGN as a string' do
        @last_moved_actor.to_s.must_equal '_'
      end
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::LastMovedActor.new('foobar') }.must_raise ArgumentError
  end
end
