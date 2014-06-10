require_relative '_test_helper'

describe Sashite::GGN::PreviousMovesCounter do
  subject { Sashite::GGN::PreviousMovesCounter }

  describe '.load' do
    describe 'null' do
      before do
        @ggn_obj = '_'
      end

      it 'loads a document from the current io stream' do
        subject.load(@ggn_obj).must_equal nil
      end

      describe 'errors' do
        it 'raises without null' do
          -> { subject.load '' }.must_raise ArgumentError
        end
      end
    end

    describe 'an unsigned integer' do
      before do
        @ggn_obj = '0'
      end

      it 'loads a document from the current io stream' do
        subject.load(@ggn_obj).must_equal 0
      end

      describe 'errors' do
        it 'raises with a negative integer' do
          -> { subject.load '-4' }.must_raise ArgumentError
        end
      end
    end
  end
end
