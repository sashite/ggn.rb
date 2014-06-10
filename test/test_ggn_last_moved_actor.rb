require_relative '_test_helper'

describe Sashite::GGN::LastMovedActor do
  subject { Sashite::GGN::LastMovedActor }

  describe '.load' do
    describe 'boolean' do
      before do
        @ggn_obj = 't'
      end

      it 'loads a document from the current io stream' do
        subject.load(@ggn_obj).must_equal true
      end

      it 'raises an error' do
        -> { subject.load 'true' }.must_raise ArgumentError
      end
    end

    describe 'null' do
      before do
        @ggn_obj = '_'
      end

      it 'loads a document from the current io stream' do
        subject.load(@ggn_obj).must_equal nil
      end

      it 'raises an error' do
        -> { subject.load '' }.must_raise ArgumentError
      end
    end
  end
end
