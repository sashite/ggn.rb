require_relative '_test_helper'

describe Sashite::GGN::MaximumMagnitude do
  subject { Sashite::GGN::MaximumMagnitude }

  describe '.load' do
    describe 'null' do
      before do
        @ggn_obj = '_'
      end

      it 'loads a document from the current io stream' do
        subject.load(@ggn_obj).must_equal nil
      end

      describe 'errors' do
        it 'raises an error' do
          -> { subject.load 'foobar' }.must_raise ArgumentError
        end
      end
    end

    describe 'an unsigned integer' do
      before do
        @ggn_obj = '42'
      end

      it 'loads a document from the current io stream' do
        subject.load(@ggn_obj).must_equal 42
      end

      describe 'errors' do
        it 'raises an error' do
          -> { subject.load '-4' }.must_raise ArgumentError
        end
      end
    end
  end
end
