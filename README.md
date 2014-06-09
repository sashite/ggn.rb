# Sashite::GGN

This module provides a Ruby interface for gameplay serialization in [GGN](http://sashite.wiki/General_Gameplay_Notation) format.

## Status

* [![Gem Version](https://badge.fury.io/rb/sashite-ggn.svg)](//badge.fury.io/rb/sashite-ggn)
* [![Build Status](https://secure.travis-ci.org/sashite/ggn.rb.svg?branch=master)](//travis-ci.org/sashite/ggn.rb?branch=master)
* [![Dependency Status](https://gemnasium.com/sashite/ggn.rb.svg)](//gemnasium.com/sashite/ggn.rb)

## Installation

Add this line to your application's Gemfile:

    gem 'sashite-ggn'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sashite-ggn

## Usage

```ruby
require 'sashite-ggn'

arr = [
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
]

gameplay = Sashite::GGN.new arr

gameplay.to_s
# => "t<self>_&_^remove[-1,0]1/t=_@f+all~_@an_enemy_actor+all%self. t<self>_&_^remove[0,-1]1/t=_@f+all~_@an_enemy_actor+all%self. t<self>_&_^remove[0,1]1/t=_@f+all~_@an_enemy_actor+all%self. t<self>_&_^remove[1,0]1/t=_@f+all~_@an_enemy_actor+all%self. t<self>_&_^shift[-1,0]_/t=_@f+all~_@f+all%self. t<self>_&_^shift[-1,0]_/t=_@f+all~_@f+all%self; t<self>_&_^remove[-1,0]1/t=_@f+all~_@an_enemy_actor+all%self. t<self>_&_^shift[0,-1]_/t=_@f+all~_@f+all%self. t<self>_&_^shift[0,-1]_/t=_@f+all~_@f+all%self; t<self>_&_^remove[0,-1]1/t=_@f+all~_@an_enemy_actor+all%self. t<self>_&_^shift[0,1]_/t=_@f+all~_@f+all%self. t<self>_&_^shift[0,1]_/t=_@f+all~_@f+all%self; t<self>_&_^remove[0,1]1/t=_@f+all~_@an_enemy_actor+all%self. t<self>_&_^shift[1,0]_/t=_@f+all~_@f+all%self. t<self>_&_^shift[1,0]_/t=_@f+all~_@f+all%self; t<self>_&_^remove[1,0]1/t=_@f+all~_@an_enemy_actor+all%self."

gameplay.to_cgh
# => "dcc5944dd91f82007904126bf2780a9922186b90"

gameplay.dimensions
# => 2
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
