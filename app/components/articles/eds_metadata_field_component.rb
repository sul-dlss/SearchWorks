# frozen_string_literal: true

module Articles
  class EdsMetadataFieldComponent < Blacklight::MetadataFieldComponent
    def truncate?
      @field.field_config.truncate
    end

    def value_attr
      return { class: "blacklight-#{@field.key}" } unless truncate?

      { class: "blacklight-#{@field.key}", data: { controller: 'long-text', 'long-text-truncate-class': 'truncate-5' } }
    end
  end
end
