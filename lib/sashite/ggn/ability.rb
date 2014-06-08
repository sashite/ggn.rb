require_relative 'subject'
require_relative 'verb'
require_relative 'object'

module Sashite
  module GGN
    class Ability
      PATTERN = /#{Subject::PATTERN}\^#{Verb::PATTERN}=#{Object::PATTERN}/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      attr_reader :subject, :verb, :object

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @subject = Subject.new str.split('^').fetch 0
        @verb    = Verb.new str.split('^').fetch(1).split('=').fetch 0
        @object  = Object.new str.split('=').fetch 1
      end

      def as_json
        {
          subject: @subject.as_json,
          verb: @verb.as_json,
          object: @object.as_json
        }
      end

      def to_s
        "#{@subject}^#{@verb}=#{@object}"
      end
    end
  end
end
