require_relative '_test_helper'

describe Sashite::GGN::Digit do
  subject { Sashite::GGN::Digit }

  describe '.load' do
    before do
      @ggn_obj = '8'
    end

    it 'loads a document from the current io stream' do
      subject.load(@ggn_obj).must_equal 8
    end

    describe 'errors' do
      it 'raises with a negative integer' do
        -> { subject.load '-4' }.must_raise ArgumentError
      end
    end
  end
end
