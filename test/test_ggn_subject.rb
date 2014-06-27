require_relative '_test_helper'

describe Sashite::GGN::Subject do
  subject { Sashite::GGN::Subject.new }

  describe '#ally' do
    it 'responds to ally' do
      subject.must_respond_to :ally
    end
  end

  describe '#ally=' do
    it 'responds to ally=' do
      subject.must_respond_to :ally=
    end
  end

  describe '#actor' do
    it 'responds to actor' do
      subject.must_respond_to :actor
    end
  end

  describe '#actor=' do
    it 'responds to actor=' do
      subject.must_respond_to :actor=
    end
  end

  describe '#state' do
    it 'responds to state' do
      subject.must_respond_to :state
    end
  end

  describe '#state=' do
    it 'responds to state=' do
      subject.must_respond_to :state=
    end
  end
end
