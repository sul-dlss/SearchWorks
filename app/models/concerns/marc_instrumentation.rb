module MarcInstrumentation
  def marc_instrumentation
    if self.respond_to?(:to_marc)
      @marc_instrumentation ||= SearchWorksMarc::Instrumentation.new(self.to_marc)
    end
  end
end
