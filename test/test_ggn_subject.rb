require_relative '_test_helper'

describe Sashite::GGN::Subject do
  describe '.new' do
    before do
      @subject = Sashite::GGN::Subject.new('t<self>_&_')
    end

    it 'returns the GGN as a JSON' do
      @subject.as_json.hash.must_equal(
        {
          :"...ally?" => true,
          :"actor" => :self,
          :"state" => {
            :"...last_moved_actor?" => nil,
            :"...previous_moves_counter" => nil
          }
        }.hash
      )
    end

    it 'returns the GGN as a string' do
      @subject.to_s.must_equal 't<self>_&_'
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::Subject.new('?<self>_&_') }.must_raise ArgumentError
  end
end
