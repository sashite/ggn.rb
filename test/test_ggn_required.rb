require_relative '_test_helper'

describe Sashite::GGN::Required do
  subject { Sashite::GGN::Required }

  describe '.load' do
    before do
      @ggn_obj = 't'
    end

    it 'loads a document from the current io stream' do
      subject.load(@ggn_obj).must_equal true
    end

    describe 'errors' do
      it 'raises without a boolean' do
        -> { subject.load 'foobar' }.must_raise ArgumentError
      end
    end
  end
end
