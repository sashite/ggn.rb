require_relative '_test_helper'

describe Sashite::GGN do
  subject { Sashite::GGN.new }

  describe 'GGN instance' do
    it 'responds to patterns' do
      subject.must_respond_to :patterns
    end

    it 'responds to patterns=' do
      subject.must_respond_to :patterns=
    end
  end
end
