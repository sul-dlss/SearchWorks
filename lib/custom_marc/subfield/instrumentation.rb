module CustomMarc
  module Subfield
    class Instrumentation < MARC::Subfield
      def to_s
        self.send("#{@code}_subfield")
      end

      private
      def a_subfield
        @value
      end

      def b_subfield
        "solo #{@value}"
      end

      def d_subfield
        "doubling #{@value}"
      end

      def n_subfield
        "(#{@value})"
      end

      def method_missing(method_name, *args, &block)
        case method_name
        when /._subfield/
          nil
        else
          super
        end
      end
    end
  end
end
