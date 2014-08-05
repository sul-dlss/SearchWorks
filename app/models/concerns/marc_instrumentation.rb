module MarcInstrumentation
  def marc_instrumentation
    if self.respond_to?(:to_marc)
      @marc_382 ||= MarcInstrumentation::Processor.new(self)
    end
  end

  class Processor
    def initialize(document)
      @marc382 = document
                  .to_marc
                  .fields
                  .select { |f| f.tag == '382' }
                  .map do |f|
                    CustomMarc::DataField::Instrumentation.new(
                      subfields: f.subfields,
                      indicator: f.indicator1
                    )
                  end
    end

    def present?
      @marc382.present?
    end

    def text
      text = ''
      dd_text = []
      @marc382.group_by{ |f| f.indicator }.each do |indicator, group|
        text += "<dt>#{indicator}</dt>"
        group.each do |g|
          dd_text.push "<dd>#{g.subfields_to_text.join(", ")}</dd>"
        end
        text += dd_text.join("")
      end
      text.html_safe
    end
  end
end
