require_relative 'subject'
require_relative 'verb'
require_relative 'object'

module Sashite
  module GGN
    module Ability
      PATTERN = /#{Subject::PATTERN}\^#{Verb::PATTERN}=#{Object::PATTERN}/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io
        raise ArgumentError unless valid? io

        subject = Subject.load io.split('^').fetch 0
        verb    = Verb.load io.split('^').fetch(1).split('=').fetch 0
        object  = Object.load io.split('=').fetch 1

        {
          subject: subject,
          verb: verb,
          object: object
        }
      end
    end
  end
end
