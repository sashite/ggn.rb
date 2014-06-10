require_relative '_test_helper'

describe Sashite::GGN::Zero do
  subject { Sashite::GGN::Zero }

  describe '.load' do
    before do
      @ggn_obj = '0'
    end

    it 'loads a document from the current io stream' do
      subject.load(@ggn_obj).must_equal 0
    end

    describe 'errors' do
      it 'raises without zero' do
        -> { subject.load '4' }.must_raise ArgumentError
      end
    end
  end
end
