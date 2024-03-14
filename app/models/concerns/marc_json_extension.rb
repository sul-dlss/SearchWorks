# frozen_string_literal: true

module MarcJsonExtension
  # Override blacklight-marc if we have marcjson available
  def load_marc
    json = begin
      value = first('marc_json_struct')

      if value.is_a?(Hash)
        value
      else
        JSON.parse(first('marc_json_struct'))
      end
    rescue JSON::ParserError
      nil
    end

    record = MARC::Record.new_from_hash(json) if json
    record || super
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
