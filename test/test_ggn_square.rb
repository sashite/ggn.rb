require_relative '_test_helper'

describe Sashite::GGN::Square do
  describe '.new' do
    before do
      @square = Sashite::GGN::Square.new('_@an_enemy_actor+all')
    end

    it 'returns the GGN as a JSON' do
      @square.as_json.hash.must_equal(
        {
          :"...attacked?" => nil,
          :"...occupied!" => :an_enemy_actor,
          :"area" => :all
        }.hash
      )
    end

    it 'returns the GGN as a string' do
      @square.to_s.must_equal '_@an_enemy_actor+all'
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::Square.new('foo') }.must_raise ArgumentError
  end
end
