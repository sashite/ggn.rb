require_relative '_test_helper'

describe Sashite::GGN::Pattern do
  subject { Sashite::GGN::Pattern.new }

  describe '#abilities' do
    it 'responds to abilities' do
      subject.must_respond_to :abilities
    end
  end

  describe '#abilities=' do
    it 'responds to abilities=' do
      subject.must_respond_to :abilities=
    end
  end
end
