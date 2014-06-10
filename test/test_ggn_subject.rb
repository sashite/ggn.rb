require_relative '_test_helper'

describe Sashite::GGN::Subject do
  subject { Sashite::GGN::Subject }

  describe '.load' do
    before do
      @ggn_obj = 't<self>_&_'
    end

    it 'loads a document from the current io stream' do
      subject.load(@ggn_obj).hash.must_equal({
        :"...ally?" => true,
        :"actor" => :self,
        :"state" => {
          :"...last_moved_actor?" => nil,
          :"...previous_moves_counter" => nil
        }
      }.hash)
    end

    describe 'errors' do
      it 'raises without a subject' do
        -> { subject.load 'foobar' }.must_raise ArgumentError
      end
    end
  end
end
