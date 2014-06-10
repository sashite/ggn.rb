require_relative '_test_helper'

describe Sashite::GGN::Ability do
  subject { Sashite::GGN::Ability }

  describe '.load' do
    before do
      @ggn_obj = 't<self>_&_^shift[-1,0]_/t=_@f+all~_@f+all%self'
    end

    it 'loads a document from the current io stream' do
      subject.load(@ggn_obj).hash.must_equal(
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

    describe 'errors' do
      it 'raises without an ability' do
        -> { subject.load 'foobar' }.must_raise ArgumentError
      end
    end
  end
end
