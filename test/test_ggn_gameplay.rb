require_relative '_test_helper'

describe Sashite::GGN::Gameplay do
  subject { Sashite::GGN::Gameplay }

  describe '.load' do
    before do
      @ggn_obj = 't<self>_&_^remove[-1,0]1/t=_@f+all~_@an_enemy_actor+all%self. ' +
                 't<self>_&_^remove[0,-1]1/t=_@f+all~_@an_enemy_actor+all%self. ' +
                 't<self>_&_^remove[0,1]1/t=_@f+all~_@an_enemy_actor+all%self. ' +
                 't<self>_&_^remove[1,0]1/t=_@f+all~_@an_enemy_actor+all%self. ' +
                 't<self>_&_^shift[-1,0]_/t=_@f+all~_@f+all%self. ' +
                 't<self>_&_^shift[-1,0]_/t=_@f+all~_@f+all%self; t<self>_&_^remove[-1,0]1/t=_@f+all~_@an_enemy_actor+all%self. ' +
                 't<self>_&_^shift[0,-1]_/t=_@f+all~_@f+all%self. ' +
                 't<self>_&_^shift[0,-1]_/t=_@f+all~_@f+all%self; t<self>_&_^remove[0,-1]1/t=_@f+all~_@an_enemy_actor+all%self. ' +
                 't<self>_&_^shift[0,1]_/t=_@f+all~_@f+all%self. ' +
                 't<self>_&_^shift[0,1]_/t=_@f+all~_@f+all%self; t<self>_&_^remove[0,1]1/t=_@f+all~_@an_enemy_actor+all%self. ' +
                 't<self>_&_^shift[1,0]_/t=_@f+all~_@f+all%self. ' +
                 't<self>_&_^shift[1,0]_/t=_@f+all~_@f+all%self; t<self>_&_^remove[1,0]1/t=_@f+all~_@an_enemy_actor+all%self.'
    end

    it 'loads a document from the current io stream' do
      subject.load(@ggn_obj).hash.must_equal(
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

    describe 'errors' do
      it 'raises with several identical gameplays' do
        -> { subject.load 't<self>_&_^remove[-1,0]1/t=_@f+all~_@an_enemy_actor+all%self. ' +
                          't<self>_&_^remove[-1,0]1/t=_@f+all~_@an_enemy_actor+all%self.' }.must_raise ArgumentError
      end
    end
  end
end
