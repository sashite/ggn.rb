require_relative '_test_helper'

describe Sashite::GGN::Ability do
  subject { Sashite::GGN::Ability.new }

  describe '#subject' do
    it 'responds to subject' do
      subject.must_respond_to :subject
    end
  end

  describe '#subject=' do
    it 'responds to subject=' do
      subject.must_respond_to :subject=
    end
  end

  describe '#verb' do
    it 'responds to verb' do
      subject.must_respond_to :verb
    end
  end

  describe '#verb=' do
    it 'responds to verb=' do
      subject.must_respond_to :verb=
    end
  end

  describe '#object' do
    it 'responds to object' do
      subject.must_respond_to :object
    end
  end

  describe '#object=' do
    it 'responds to object=' do
      subject.must_respond_to :object=
    end
  end
end
