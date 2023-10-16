require 'rails_helper'

RSpec.describe FolioJsonExport do
  let(:document) do
    SolrDocument.new(
      id: '123',
      holdings_json_struct: [{ 'holdings_key' => 'holdings_value' }],
      folio_json_struct: [{ "folio_key" => "folio_value" }.to_json]
    )
  end
  let(:empty_content_document) do
    SolrDocument.new(id: '456', holdings_json_struct: [], folio_json_struct: [].to_json)
  end
  let(:no_key_document) do
    SolrDocument.new(id: '789')
  end

  describe '#will_export_as' do
    it 'true when folio_json_struct value contains content' do
      expect(document.export_formats.key?(:folio_json)).to be true
    end

    it 'true when folio_json_struct value is an empty array' do
      expect(empty_content_document.export_formats.key?(:folio_json)).to be true
    end

    it 'false when folio_json_struct key is missing' do
      expect(no_key_document.export_formats.key?(:folio_json)).to be false
    end
  end

  describe '#export_as_folio_json' do
    it 'returns data when FOLIO JSON is present' do
      expect(document.export_as_folio_json).to include 'holdings_value'
      expect(document.export_as_folio_json).to include 'folio_value'
    end
  end
end
