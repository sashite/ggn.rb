require_relative '_test_helper'

describe Sashite::GGN::Object do
  subject { Sashite::GGN::Object }

  describe '.load' do
    before do
      @ggn_obj = '_@f+all~_@f+all%self'
    end

    it 'loads a document from the current io stream' do
      subject.load(@ggn_obj).hash.must_equal({
        src_square: {
          :"...attacked?" => nil,
          :"...occupied!" => false,
          area: :all
        },
        dst_square: {
          :"...attacked?" => nil,
          :"...occupied!" => false,
          area: :all
        },
        promotable_into_actors: [:self]
      }.hash)
    end

    describe 'errors' do
      it 'raises without an object' do
        -> { subject.load 'foo' }.must_raise ArgumentError
      end
    end
  end
end
