module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def document_partial_name(document, base_name = nil)
    document.display_type || 'default'
  end
end
