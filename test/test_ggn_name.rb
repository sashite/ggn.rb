require_relative '_test_helper'

describe Sashite::GGN::Name do
  subject { Sashite::GGN::Name }

  describe '.load' do
    before do
      @ggn_obj = 'capture'
    end

    it 'loads a document from the current io stream' do
      subject.load(@ggn_obj).must_equal :capture
    end

    describe 'errors' do
      it 'raises an error' do
        -> { subject.load 'foobar' }.must_raise ArgumentError
      end
    end
  end
end
