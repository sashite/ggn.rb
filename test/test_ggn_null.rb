require_relative '_test_helper'

describe Sashite::GGN::Null do
  subject { Sashite::GGN::Null }

  describe '.load' do
    before do
      @ggn_obj = '_'
    end

    it 'loads a document from the current io stream' do
      subject.load(@ggn_obj).must_equal nil
    end

    describe 'errors' do
      it 'raises without null' do
        -> { subject.load '4' }.must_raise ArgumentError
      end
    end
  end
end
