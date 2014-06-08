require_relative '_test_helper'

describe Sashite::GGN::Area do
  describe '.new' do
    describe 'all' do
      before do
        @area = Sashite::GGN::Area.new('all')
      end

      it 'returns the GGN as a JSON' do
        @area.as_json.must_equal :all
      end

      it 'returns the GGN as a string' do
        @area.to_s.must_equal 'all'
      end
    end

    describe 'furthest rank' do
      before do
        @area = Sashite::GGN::Area.new('furthest_rank')
      end

      it 'returns the GGN as a JSON' do
        @area.as_json.must_equal :furthest_rank
      end

      it 'returns the GGN as a string' do
        @area.to_s.must_equal 'furthest_rank'
      end
    end

    describe 'palace' do
      before do
        @area = Sashite::GGN::Area.new('palace')
      end

      it 'returns the GGN as a JSON' do
        @area.as_json.must_equal :palace
      end

      it 'returns the GGN as a string' do
        @area.to_s.must_equal 'palace'
      end
    end

    describe 'furthest one-third' do
      before do
        @area = Sashite::GGN::Area.new('furthest_one-third')
      end

      it 'returns the GGN as a JSON' do
        @area.as_json.must_equal :'furthest_one-third'
      end

      it 'returns the GGN as a string' do
        @area.to_s.must_equal 'furthest_one-third'
      end
    end

    describe 'nearest two-thirds' do
      before do
        @area = Sashite::GGN::Area.new('nearest_two-thirds')
      end

      it 'returns the GGN as a JSON' do
        @area.as_json.must_equal :'nearest_two-thirds'
      end

      it 'returns the GGN as a string' do
        @area.to_s.must_equal 'nearest_two-thirds'
      end
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::Area.new('foobar') }.must_raise ArgumentError
  end
end
