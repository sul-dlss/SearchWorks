require 'rails_helper'

RSpec.describe EdsExport do
  let(:document) do
    SolrDocument.new(
      id: '123',
      eds_citation_exports: [{ 'id' => 'RIS', 'data' => 'TI  - CatZ N Bagelz' }]
    )
  end
  let(:empty_document) do
    SolrDocument.new(id: '456', eds_citation_exports: [])
  end

  describe '#will_export_as' do
    it 'true when RIS citation is present' do
      expect(document.export_formats.key?(:ris)).to be true
    end

    it 'nil when RIS citation is not available' do
      expect(empty_document.export_formats.key?(:ris)).to be false
    end
  end

  describe '#export_as_ris' do
    it 'returns data when RIS citation is present' do
      expect(document.export_as_ris).to eq 'TI  - CatZ N Bagelz'
    end

    it 'returns nil when RIS citation is not available' do
      expect(empty_document.export_as_ris).to be_nil
    end
  end
end
