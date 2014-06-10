require_relative 'boolean'
require_relative 'null'
require_relative 'subject'

module Sashite
  module GGN
    module Occupied
      PATTERN = /(#{Null::PATTERN}|#{Boolean::PATTERN}|#{Subject::PATTERN}|an_ally_actor|an_enemy_actor)/

      def self.valid? io
        !!io.match("^#{PATTERN}$")
      end

      def self.load io
        raise ArgumentError unless valid? io

        if Null.valid? io
          Null.load
        elsif Boolean.valid? io
          Boolean.load io
        elsif Subject.valid? io
          Subject.load io
        else
          io.to_sym
        end
      end
    end
  end
end
