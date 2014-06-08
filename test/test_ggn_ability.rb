require_relative '_test_helper'

describe Sashite::GGN::Ability do
  describe '.new' do
    before do
      @ability = Sashite::GGN::Ability.new('t<self>_&_^shift[-1,0]_/t=_@f+all~_@f+all%self')
    end

    it 'returns the GGN as a JSON' do
      @ability.as_json.hash.must_equal(
        {
          subject: {
            :"...ally?" => true,
            :"actor" => :self,
            :"state" => {
              :"...last_moved_actor?" => nil,
              :"...previous_moves_counter" => nil
            }
          },

          verb: {
            name: :shift,
            vector: {direction: [-1,0], :"...maximum_magnitude" => nil}
          },

          object: {
            src_square: {
              :"...attacked?" => nil,
              :"...occupied!" => false,
              area: :all
            },
            dst_square: {
              :"...attacked?" => nil,
              :"...occupied!" => false,
              area: :all
            },
            promotable_into_actors: [:self]
          }
        }.hash
      )
    end

    it 'returns the GGN as a string' do
      @ability.to_s.must_equal 't<self>_&_^shift[-1,0]_/t=_@f+all~_@f+all%self'
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::Ability.new('foobar') }.must_raise ArgumentError
  end
end
