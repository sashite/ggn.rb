require_relative '_test_helper'

describe Sashite::GGN::NegativeInteger do
  subject { Sashite::GGN::NegativeInteger }

  describe '.load' do
    before do
      @ggn_obj = '-42'
    end

    it 'loads a document from the current io stream' do
      subject.load(@ggn_obj).must_equal -42
    end

    describe 'errors' do
      it 'raises with an unsigned integer' do
        -> { subject.load '4' }.must_raise ArgumentError
      end
    end
  end
end
