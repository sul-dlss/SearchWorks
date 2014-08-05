module CustomMarc
  module DataField
    class Instrumentation < MARC::DataField
      def initialize(options = {})
        @subfields = options[:subfields]
          .try(:map) { |s| CustomMarc::Subfield::Instrumentation.new(s.code, s.value) }
        @indicator = options[:indicator]
      end

      def subfields_to_text
        text_array = []
        j = 0
        @subfields.each_with_index do |field, i|
          if field.code == 'n'
            append_to_previous field.to_s, text_array, i - 1 - j
            j += 1
          else
            text_array.push field.to_s
          end
        end
        text_array.compact
      end

      def indicator
        self.send("indicator_#{@indicator}")
      end

      def append_to_previous field, array, index
        array[index] = "#{array[index]} #{field}"
      end
      
      private
      def indicator_0
        'Instrumentation'
      end

      def indicator_1
        'Partial instrumentation'
      end

      def method_missing(method_name, *args, &block)
        case method_name
        when /indicator_./
          nil
        else
          super
        end
      end
    end
  end
end
