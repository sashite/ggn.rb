require_relative '_test_helper'

describe Sashite::GGN::State do
  subject { Sashite::GGN::State.new }

  describe '#last_moved_actor' do
    it 'responds to last_moved_actor' do
      subject.must_respond_to :last_moved_actor
    end
  end

  describe '#last_moved_actor=' do
    it 'responds to last_moved_actor=' do
      subject.must_respond_to :last_moved_actor=
    end
  end

  describe '#previous_moves_counter' do
    it 'responds to previous_moves_counter' do
      subject.must_respond_to :previous_moves_counter
    end
  end

  describe '#previous_moves_counter=' do
    it 'responds to previous_moves_counter=' do
      subject.must_respond_to :previous_moves_counter=
    end
  end
end
