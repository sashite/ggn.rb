require_relative '_test_helper'

describe Sashite::GGN::Square do
  subject { Sashite::GGN::Square }

  describe '.load' do
    before do
      @ggn_obj = '_@an_enemy_actor+all'
    end

    it 'loads a document from the current io stream' do
      subject.load(@ggn_obj).hash.must_equal({
        :"...attacked?" => nil,
        :"...occupied!" => :an_enemy_actor,
        :"area" => :all
      }.hash)
    end

    describe 'errors' do
      it 'raises witout a square' do
        -> { subject.load 'foobar' }.must_raise ArgumentError
      end
    end
  end
end
