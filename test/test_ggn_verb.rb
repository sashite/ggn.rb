require_relative '_test_helper'

describe Sashite::GGN::Verb do
  subject { Sashite::GGN::Verb }

  describe '.load' do
    before do
      @ggn_obj = 'shift[4,2]42/t'
    end

    it 'loads a document from the current io stream' do
      subject.load(@ggn_obj).hash.must_equal({
        name: :shift,
        vector: {
          direction: [4,2],
          :"...maximum_magnitude" => 42
        }
      }.hash)
    end

    describe 'errors' do
      it 'raises without a verb structure' do
        -> { subject.load 'foobar' }.must_raise ArgumentError
      end
    end
  end
end
