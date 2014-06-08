module Sashite
  module GGN
    class Name
      PATTERN = /(capture|remove|shift)/

      def self.valid? str
        !!str.match("^#{PATTERN}$")
      end

      def initialize str
        raise ArgumentError unless self.class.valid? str

        @value = str.to_sym
      end

      def as_json
        @value
      end

      def to_s
        @value.to_s
      end
    end
  end
end
