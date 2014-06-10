require_relative '_test_helper'

describe Sashite::GGN::Integer do
  subject { Sashite::GGN::Integer }

  describe '.load' do
    describe 'negative integer' do
      before do
        @ggn_obj = '-42'
      end

      it 'loads a document from the current io stream' do
        subject.load(@ggn_obj).must_equal -42
      end

      describe 'errors' do
        it 'raises with the opposite of zero' do
          -> { subject.load '-0' }.must_raise ArgumentError
        end
      end
    end

    describe 'unsigned integer' do
      before do
        @ggn_obj = '42'
      end

      it 'loads a document from the current io stream' do
        subject.load(@ggn_obj).must_equal 42
      end

      describe 'errors' do
        it 'raises with an integer beginning by zero' do
          -> { subject.load '04' }.must_raise ArgumentError
        end
      end
    end
  end
end
