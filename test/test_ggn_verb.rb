require_relative '_test_helper'

describe Sashite::GGN::Verb do
  subject { Sashite::GGN::Verb.new }

  describe '#name' do
    it 'responds to name' do
      subject.must_respond_to :name
    end
  end

  describe '#name=' do
    it 'responds to name=' do
      subject.must_respond_to :name=
    end
  end

  describe '#vector' do
    it 'responds to vector' do
      subject.must_respond_to :vector
    end
  end

  describe '#vector=' do
    it 'responds to vector=' do
      subject.must_respond_to :vector=
    end
  end
end
