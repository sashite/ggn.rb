require_relative 'boolean'
require_relative 'null'
require_relative 'subject'

module Sashite
  module GGN
    class Occupied
      PATTERN = /(#{Null::PATTERN}|#{Boolean::PATTERN}|#{Subject::PATTERN}|an_ally_actor|an_enemy_actor)/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @value = if Null.valid? str
          Null.instance
        elsif Boolean.valid? str
          Boolean.new str
        elsif Subject.valid? str
          Subject.new str
        else
          str.to_sym
        end
      end

      def as_json
        @value.is_a?(Symbol) ? @value : @value.as_json
      end

      def to_s
        @value.to_s
      end
    end
  end
end
