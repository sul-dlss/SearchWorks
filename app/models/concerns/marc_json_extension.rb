module MarcJsonExtension
  # Override blacklight-marc if we have marcjson available
  def _marc_source_field
    :marcjson_ss
  end

  # Override blacklight-marc if we have marcjson available
  def _marc_format_type
    :json
  end
end
