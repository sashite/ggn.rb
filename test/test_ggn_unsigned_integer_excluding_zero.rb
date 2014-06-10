require_relative '_test_helper'

describe Sashite::GGN::UnsignedIntegerExcludingZero do
  subject { Sashite::GGN::UnsignedIntegerExcludingZero }

  describe '.load' do
    before do
      @ggn_obj = '42'
    end

    it 'loads a document from the current io stream' do
      subject.load(@ggn_obj).must_equal 42
    end

    describe 'errors' do
      it 'raises with a negative integer' do
        -> { subject.load '-42' }.must_raise ArgumentError
      end

      it 'raises with a zero' do
        -> { subject.load '0' }.must_raise ArgumentError
      end
    end
  end
end
