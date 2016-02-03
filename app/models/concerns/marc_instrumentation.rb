module MarcInstrumentation
  def marc_instrumentation
    return unless respond_to?(:to_marc)
    @marc_instrumentation ||= Instrumentation.new(self)
  end
end
