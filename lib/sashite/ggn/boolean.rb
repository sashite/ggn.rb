module Sashite
  module GGN
    class Boolean
      PATTERN = /[ft]/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @value = str.to_sym
      end

      def as_json
        @value == :t
      end

      def to_s
        @value.to_s
      end
    end
  end
end
