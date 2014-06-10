require_relative '_test_helper'

describe Sashite::GGN::State do
  subject { Sashite::GGN::State }

  describe '.load' do
    before do
      @ggn_obj = 't&_'
    end

    it 'loads a document from the current io stream' do
      subject.load(@ggn_obj).hash.must_equal({
        :"...last_moved_actor?" => true,
        :"...previous_moves_counter" => nil
      }.hash)
    end

    describe 'errors' do
      it 'raises without a state' do
        -> { subject.load 'foobar' }.must_raise ArgumentError
      end
    end
  end
end
