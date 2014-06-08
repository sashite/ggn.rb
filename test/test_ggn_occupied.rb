require_relative '_test_helper'

describe Sashite::GGN::Occupied do
  describe '.new' do
    describe 'an ally actor' do
      before do
        @occupied = Sashite::GGN::Occupied.new('an_ally_actor')
      end

      it 'returns the GGN as a JSON' do
        @occupied.as_json.must_equal :an_ally_actor
      end

      it 'returns the GGN as a string' do
        @occupied.to_s.must_equal 'an_ally_actor'
      end
    end

    describe 'an enemy actor' do
      before do
        @occupied = Sashite::GGN::Occupied.new('an_enemy_actor')
      end

      it 'returns the GGN as a JSON' do
        @occupied.as_json.must_equal :an_enemy_actor
      end

      it 'returns the GGN as a string' do
        @occupied.to_s.must_equal 'an_enemy_actor'
      end
    end

    describe 'null' do
      before do
        @occupied = Sashite::GGN::Occupied.new('_')
      end

      it 'returns the GGN as a JSON' do
        @occupied.as_json.must_equal nil
      end

      it 'returns the GGN as a string' do
        @occupied.to_s.must_equal '_'
      end
    end

    describe 'true' do
      before do
        @occupied = Sashite::GGN::Occupied.new('t')
      end

      it 'returns the GGN as a JSON' do
        @occupied.as_json.must_equal true
      end

      it 'returns the GGN as a string' do
        @occupied.to_s.must_equal 't'
      end
    end

    describe 'false' do
      before do
        @occupied = Sashite::GGN::Occupied.new('f')
      end

      it 'returns the GGN as a JSON' do
        @occupied.as_json.must_equal false
      end

      it 'returns the GGN as a string' do
        @occupied.to_s.must_equal 'f'
      end
    end

    describe 'a subject' do
      before do
        @occupied = Sashite::GGN::Occupied.new('f<self>_&_')
      end

      it 'returns the GGN as a JSON' do
        @occupied.as_json.hash.must_equal(
          {
            :"...ally?" => false,
            actor: :self,
            state: {
              :"...last_moved_actor?" => nil,
              :"...previous_moves_counter" => nil
            }
          }.hash
        )
      end

      it 'returns the GGN as a string' do
        @occupied.to_s.must_equal 'f<self>_&_'
      end
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::Occupied.new('foobar') }.must_raise ArgumentError
  end
end
