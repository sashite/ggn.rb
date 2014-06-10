require_relative '_test_helper'

describe Sashite::GGN::Occupied do
  subject { Sashite::GGN::Occupied }

  describe '.load' do
    describe 'a relationship' do
      before do
        @ggn_obj = 'an_ally_actor'
      end

      it 'loads a document from the current io stream' do
        subject.load(@ggn_obj).must_equal :an_ally_actor
      end

      describe 'errors' do
        it 'raises without a relationship' do
          -> { subject.load 'foobar' }.must_raise ArgumentError
        end
      end
    end

    describe 'a boolean' do
      before do
        @ggn_obj = 'f'
      end

      it 'loads a document from the current io stream' do
        subject.load(@ggn_obj).must_equal false
      end

      describe 'errors' do
        it 'raises without a boolean' do
          -> { subject.load 'foobar' }.must_raise ArgumentError
        end
      end
    end

    describe 'null' do
      before do
        @ggn_obj = '_'
      end

      it 'loads a document from the current io stream' do
        subject.load(@ggn_obj).must_equal nil
      end

      describe 'errors' do
        it 'raises without null' do
          -> { subject.load '' }.must_raise ArgumentError
        end
      end
    end

    describe 'a subject' do
      before do
        @ggn_obj = 'f<self>_&_'
      end

      it 'loads a document from the current io stream' do
        subject.load(@ggn_obj).hash.must_equal({
          :"...ally?" => false,
          actor: :self,
          state: {
            :"...last_moved_actor?" => nil,
            :"...previous_moves_counter" => nil
          }
        }.hash)
      end

      describe 'errors' do
        it 'raises without a well-formed subject' do
          -> { subject.load 'f<foo>_&_' }.must_raise ArgumentError
        end
      end
    end
  end
end
