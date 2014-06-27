require_relative '_test_helper'

describe Sashite::GGN::Object do
  subject { Sashite::GGN::Object.new }

  describe '#src_square' do
    it 'responds to src_square' do
      subject.must_respond_to :src_square
    end
  end

  describe '#src_square=' do
    it 'responds to src_square=' do
      subject.must_respond_to :src_square=
    end
  end

  describe '#dst_square' do
    it 'responds to dst_square' do
      subject.must_respond_to :dst_square
    end
  end

  describe '#dst_square=' do
    it 'responds to dst_square=' do
      subject.must_respond_to :dst_square=
    end
  end

  describe '#promotable_into_actors' do
    it 'responds to promotable_into_actors' do
      subject.must_respond_to :promotable_into_actors
    end
  end

  describe '#promotable_into_actors=' do
    it 'responds to promotable_into_actors=' do
      subject.must_respond_to :promotable_into_actors=
    end
  end
end
