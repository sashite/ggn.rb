require_relative '_test_helper'

describe Sashite::GGN::Self do
  subject { Sashite::GGN::Self }

  describe '.load' do
    before do
      @ggn_obj = 'self'
    end

    it 'loads a document from the current io stream' do
      subject.load(@ggn_obj).must_equal :self
    end

    describe 'errors' do
      it 'raises without self' do
        -> { subject.load '42' }.must_raise ArgumentError
      end
    end
  end
end
