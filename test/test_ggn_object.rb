require_relative '_test_helper'

describe Sashite::GGN::Object do
  describe '.new' do
    before do
      @object = Sashite::GGN::Object.new('_@f+all~_@f+all%self')
    end

    it 'returns the GGN as a JSON' do
      @object.as_json.hash.must_equal(
        {
          src_square: {
            :"...attacked?" => nil,
            :"...occupied!" => false,
            area: :all
          },
          dst_square: {
            :"...attacked?" => nil,
            :"...occupied!" => false,
            area: :all
          },
          promotable_into_actors: [:self]
        }.hash
      )
    end

    it 'returns the GGN as a string' do
      @object.to_s.must_equal '_@f+all~_@f+all%self'
    end
  end

  it 'raises an error' do
    -> { Sashite::GGN::Object.new('foo') }.must_raise ArgumentError
  end
end
