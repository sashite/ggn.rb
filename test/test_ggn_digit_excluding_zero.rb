require_relative '_test_helper'

describe Sashite::GGN::DigitExcludingZero do
  subject { Sashite::GGN::DigitExcludingZero }

  describe '.load' do
    before do
      @ggn_obj = '8'
    end

    it 'loads a document from the current io stream' do
      subject.load(@ggn_obj).must_equal 8
    end

    describe 'errors' do
      it 'raises with zero' do
        -> { subject.load '0' }.must_raise ArgumentError
      end
    end
  end
end
