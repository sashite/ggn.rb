require_relative '_test_helper'

describe Sashite::GGN::GameplayIntoBase64 do
  describe '.new' do
    before do
      @gameplay_into_base64 = Sashite::GGN::GameplayIntoBase64.new('dDxzZWxmPl8mX15yZW1vdmVbLTEsMF0xL3Q9X0BmK2FsbH5fQGFuX2VuZW15X2FjdG9yK2FsbCVzZWxmLiB0PHNlbGY+XyZfXnJlbW92ZVswLC0xXTEvdD1fQGYrYWxsfl9AYW5fZW5lbXlfYWN0b3IrYWxsJXNlbGYuIHQ8c2VsZj5fJl9ecmVtb3ZlWzAsMV0xL3Q9X0BmK2FsbH5fQGFuX2VuZW15X2FjdG9yK2FsbCVzZWxmLiB0PHNlbGY+XyZfXnJlbW92ZVsxLDBdMS90PV9AZithbGx+X0Bhbl9lbmVteV9hY3RvcithbGwlc2VsZi4gdDxzZWxmPl8mX15zaGlmdFstMSwwXV8vdD1fQGYrYWxsfl9AZithbGwlc2VsZi4gdDxzZWxmPl8mX15zaGlmdFstMSwwXV8vdD1fQGYrYWxsfl9AZithbGwlc2VsZjsgdDxzZWxmPl8mX15yZW1vdmVbLTEsMF0xL3Q9X0BmK2FsbH5fQGFuX2VuZW15X2FjdG9yK2FsbCVzZWxmLiB0PHNlbGY+XyZfXnNoaWZ0WzAsLTFdXy90PV9AZithbGx+X0BmK2FsbCVzZWxmLiB0PHNlbGY+XyZfXnNoaWZ0WzAsLTFdXy90PV9AZithbGx+X0BmK2FsbCVzZWxmOyB0PHNlbGY+XyZfXnJlbW92ZVswLC0xXTEvdD1fQGYrYWxsfl9AYW5fZW5lbXlfYWN0b3IrYWxsJXNlbGYuIHQ8c2VsZj5fJl9ec2hpZnRbMCwxXV8vdD1fQGYrYWxsfl9AZithbGwlc2VsZi4gdDxzZWxmPl8mX15zaGlmdFswLDFdXy90PV9AZithbGx+X0BmK2FsbCVzZWxmOyB0PHNlbGY+XyZfXnJlbW92ZVswLDFdMS90PV9AZithbGx+X0Bhbl9lbmVteV9hY3RvcithbGwlc2VsZi4gdDxzZWxmPl8mX15zaGlmdFsxLDBdXy90PV9AZithbGx+X0BmK2FsbCVzZWxmLiB0PHNlbGY+XyZfXnNoaWZ0WzEsMF1fL3Q9X0BmK2FsbH5fQGYrYWxsJXNlbGY7IHQ8c2VsZj5fJl9ecmVtb3ZlWzEsMF0xL3Q9X0BmK2FsbH5fQGFuX2VuZW15X2FjdG9yK2FsbCVzZWxmLg==')
    end

    it 'returns the GGN as a JSON' do
      @gameplay_into_base64.as_json.hash.must_equal(
        [
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
                :"name" => :remove,
                :"vector" => {:"...maximum_magnitude" => 1, direction: [-1,0]}
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
          ],



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
                :"name" => :remove,
                :"vector" => {:"...maximum_magnitude" => 1, direction: [0,-1]}
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
          ],



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
                :"name" => :remove,
                :"vector" => {:"...maximum_magnitude" => 1, direction: [0,1]}
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
          ],



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
                :"name" => :remove,
                :"vector" => {:"...maximum_magnitude" => 1, direction: [1,0]}
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
          ],



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
                :"vector" => {:"...maximum_magnitude" => nil, direction: [-1,0]}
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
            }
          ],



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
                :"vector" => {:"...maximum_magnitude" => nil, direction: [-1,0]}
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
                :"vector" => {:"...maximum_magnitude" => 1, direction: [-1,0]}
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
          ],



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
                :"vector" => {:"...maximum_magnitude" => nil, direction: [0,-1]}
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
            }
          ],



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
                :"vector" => {:"...maximum_magnitude" => nil, direction: [0,-1]}
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
                :"vector" => {:"...maximum_magnitude" => 1, direction: [0,-1]}
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
          ],



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
                :"vector" => {:"...maximum_magnitude" => nil, direction: [0,1]}
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
            }
          ],



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
                :"vector" => {:"...maximum_magnitude" => nil, direction: [0,1]}
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
                :"vector" => {:"...maximum_magnitude" => 1, direction: [0,1]}
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
          ],



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
                :"vector" => {:"...maximum_magnitude" => nil, direction: [1,0]}
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
            }
          ],



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
                :"vector" => {:"...maximum_magnitude" => nil, direction: [1,0]}
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
                :"vector" => {:"...maximum_magnitude" => 1, direction: [1,0]}
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
          ]
        ].hash
      )
    end

    it 'returns the GGN as a string' do
      @gameplay_into_base64.to_s.must_equal 'dDxzZWxmPl8mX15yZW1vdmVbLTEsMF0xL3Q9X0BmK2FsbH5fQGFuX2VuZW15X2FjdG9yK2FsbCVzZWxmLiB0PHNlbGY+XyZfXnJlbW92ZVswLC0xXTEvdD1fQGYrYWxsfl9AYW5fZW5lbXlfYWN0b3IrYWxsJXNlbGYuIHQ8c2VsZj5fJl9ecmVtb3ZlWzAsMV0xL3Q9X0BmK2FsbH5fQGFuX2VuZW15X2FjdG9yK2FsbCVzZWxmLiB0PHNlbGY+XyZfXnJlbW92ZVsxLDBdMS90PV9AZithbGx+X0Bhbl9lbmVteV9hY3RvcithbGwlc2VsZi4gdDxzZWxmPl8mX15zaGlmdFstMSwwXV8vdD1fQGYrYWxsfl9AZithbGwlc2VsZi4gdDxzZWxmPl8mX15zaGlmdFstMSwwXV8vdD1fQGYrYWxsfl9AZithbGwlc2VsZjsgdDxzZWxmPl8mX15yZW1vdmVbLTEsMF0xL3Q9X0BmK2FsbH5fQGFuX2VuZW15X2FjdG9yK2FsbCVzZWxmLiB0PHNlbGY+XyZfXnNoaWZ0WzAsLTFdXy90PV9AZithbGx+X0BmK2FsbCVzZWxmLiB0PHNlbGY+XyZfXnNoaWZ0WzAsLTFdXy90PV9AZithbGx+X0BmK2FsbCVzZWxmOyB0PHNlbGY+XyZfXnJlbW92ZVswLC0xXTEvdD1fQGYrYWxsfl9AYW5fZW5lbXlfYWN0b3IrYWxsJXNlbGYuIHQ8c2VsZj5fJl9ec2hpZnRbMCwxXV8vdD1fQGYrYWxsfl9AZithbGwlc2VsZi4gdDxzZWxmPl8mX15zaGlmdFswLDFdXy90PV9AZithbGx+X0BmK2FsbCVzZWxmOyB0PHNlbGY+XyZfXnJlbW92ZVswLDFdMS90PV9AZithbGx+X0Bhbl9lbmVteV9hY3RvcithbGwlc2VsZi4gdDxzZWxmPl8mX15zaGlmdFsxLDBdXy90PV9AZithbGx+X0BmK2FsbCVzZWxmLiB0PHNlbGY+XyZfXnNoaWZ0WzEsMF1fL3Q9X0BmK2FsbH5fQGYrYWxsJXNlbGY7IHQ8c2VsZj5fJl9ecmVtb3ZlWzEsMF0xL3Q9X0BmK2FsbH5fQGFuX2VuZW15X2FjdG9yK2FsbCVzZWxmLg=='
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::GameplayIntoBase64.new('foobar') }.must_raise ArgumentError
  end
end
