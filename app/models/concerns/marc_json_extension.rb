module MarcJsonExtension
  # Override blacklight-marc if we have marcjson available
  def _marc_source_field
    :marc_json_struct
  end

  # Override blacklight-marc if we have marcjson available
  def _marc_format_type
    :json
  end

  def as_json
    super.merge(marcxml: solrmarc_style_marcxml)
  end

  def solrmarc_style_marcxml
    <<-EOXML
      <?xml version="1.0" encoding="UTF-8"?><collection xmlns="http://www.loc.gov/MARC21/slim">
        #{export_as_marcxml}
      </collection>
    EOXML
  end
end
