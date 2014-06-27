require_relative '_test_helper'

describe Sashite::GGN::Gameplay do
  subject { Sashite::GGN::Gameplay.new }

  describe '#patterns' do
    it 'responds to patterns' do
      subject.must_respond_to :patterns
    end
  end

  describe '#patterns=' do
    it 'responds to patterns=' do
      subject.must_respond_to :patterns=
    end
  end
end
