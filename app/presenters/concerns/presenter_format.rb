# frozen_string_literal: true

module PresenterFormat
  def formats
    field_key = configuration.index.display_type_field
    document[field_key]
  end
end
