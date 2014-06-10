require_relative '_test_helper'

describe Sashite::GGN::Area do
  subject { Sashite::GGN::Area }

  describe '.load' do
    before do
      @ggn_obj = 'furthest_rank'
    end

    it 'loads a document from the current io stream' do
      subject.load(@ggn_obj).must_equal :furthest_rank
    end

    describe 'errors' do
      it 'raises without an area' do
        -> { subject.load 'foobar' }.must_raise ArgumentError
      end
    end
  end
end
