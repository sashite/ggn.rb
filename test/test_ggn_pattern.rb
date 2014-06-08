require_relative '_test_helper'

describe Sashite::GGN::Pattern do
  describe '.new' do
    before do
      @pattern = Sashite::GGN::Pattern.new('t<self>_&_^shift[-1,0]_/t=_@f+all~_@f+all%self; t<self>_&_^remove[-1,0]1/t=_@f+all~_@an_enemy_actor+all%self')
    end

    it 'returns the GGN as a JSON' do
      @pattern.as_json.hash.must_equal(
        [
          {
            :"subject" => {
              :"...ally?" => true,
              :"actor" => :self,
              :"state" => {
                :"...last_moved_actor?" => nil,
                :"...previous_moves_counter" => nil
              }
            },
       
            :"verb" => {
              :"name" => :shift,
              :"vector" => {:"...maximum_magnitude" => nil, :direction => [-1,0]}
            },
       
            :"object" => {
              :"src_square" => {
                :"...attacked?" => nil,
                :"...occupied!" => false,
                :"area" => :all
              },
              :"dst_square" => {
                :"...attacked?" => nil,
                :"...occupied!" => false,
                :"area" => :all
              },
              :"promotable_into_actors" => [:self]
            }
          },
          {
            :"subject" => {
              :"...ally?" => true,
              :"actor" => :self,
              :"state" => {
                :"...last_moved_actor?" => nil,
                :"...previous_moves_counter" => nil
              }
            },
       
            :"verb" => {
              :"name" => :remove,
              :"vector" => {:"...maximum_magnitude" => 1, :direction => [-1,0]}
            },
       
            :"object" => {
              :"src_square" => {
                :"...attacked?" => nil,
                :"...occupied!" => false,
                :"area" => :all
              },
              :"dst_square" => {
                :"...attacked?" => nil,
                :"...occupied!" => :an_enemy_actor,
                :"area" => :all
              },
              :"promotable_into_actors" => [:self]
            }
          }
        ].hash
      )
    end

    it 'returns the GGN as a string' do
      @pattern.to_s.must_equal 't<self>_&_^shift[-1,0]_/t=_@f+all~_@f+all%self; t<self>_&_^remove[-1,0]1/t=_@f+all~_@an_enemy_actor+all%self'
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::Pattern.new('foobar') }.must_raise ArgumentError
  end
end
