# Sashite::GGN

A collection of mappers for [GGN](http://sashite.wiki/General_Gameplay_Notation) objects.

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

Working with GGN can be very simple, for example:

```ruby
require 'sashite-ggn'

state = Sashite::GGN::State.new
state.last_moved_actor       = nil
state.previous_moves_counter = nil

subject = Sashite::GGN::Subject.new
subject.ally  = true
subject.actor = :self
subject.state = state
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
