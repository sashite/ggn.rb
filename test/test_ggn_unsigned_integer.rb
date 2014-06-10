require_relative '_test_helper'

describe Sashite::GGN::UnsignedInteger do
  subject { Sashite::GGN::UnsignedInteger }

  describe '.load' do
    describe 'a zero' do
      before do
        @ggn_obj = '0'
      end

      it 'loads a document from the current io stream' do
        subject.load(@ggn_obj).must_equal 0
      end

      describe 'errors' do
        it 'raises with a double zero' do
          -> { subject.load '00' }.must_raise ArgumentError
        end
      end
    end

    describe 'an unsigned integer excluding zero' do
      before do
        @ggn_obj = '42'
      end

      it 'loads a document from the current io stream' do
        subject.load(@ggn_obj).must_equal 42
      end

      describe 'errors' do
        it 'raises with a negative integer' do
          -> { subject.load '-4' }.must_raise ArgumentError
        end
      end
    end
  end
end
