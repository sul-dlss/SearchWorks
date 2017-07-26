module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def document_partial_name(document, base_name = nil)
    view_config = blacklight_config.view_config(:show)

    display_type = if base_name and view_config.has_key? :"#{base_name}_display_type_field"
      document[view_config[:"#{base_name}_display_type_field"]]
    end

    display_type ||= document.display_type

    display_type ||= document['eds_publication_type']

    display_type ||= 'default'

    type = type_field_to_partial_name(document, display_type.downcase)

    type
  end
end
