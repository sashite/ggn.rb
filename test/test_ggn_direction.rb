require_relative '_test_helper'

describe Sashite::GGN::Direction do
  subject { Sashite::GGN::Direction }

  describe '.load' do
    before do
      @ggn_obj = '0,1,2,3,4'
    end

    it 'loads a document from the current io stream' do
      subject.load(@ggn_obj).must_equal [ 0, 1, 2, 3, 4 ]
    end

    describe 'errors' do
      it 'raises without integers' do
        -> { subject.load '4,bar' }.must_raise ArgumentError
      end
    end
  end
end
