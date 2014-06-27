require_relative '_test_helper'

describe Sashite::GGN::Square do
  subject { Sashite::GGN::Square.new }

  describe '#attacked' do
    it 'responds to attacked' do
      subject.must_respond_to :attacked
    end
  end

  describe '#attacked=' do
    it 'responds to attacked=' do
      subject.must_respond_to :attacked=
    end
  end

  describe '#occupied' do
    it 'responds to occupied' do
      subject.must_respond_to :occupied
    end
  end

  describe '#occupied=' do
    it 'responds to occupied=' do
      subject.must_respond_to :occupied=
    end
  end

  describe '#area' do
    it 'responds to area' do
      subject.must_respond_to :area
    end
  end

  describe '#area=' do
    it 'responds to area=' do
      subject.must_respond_to :area=
    end
  end
end
