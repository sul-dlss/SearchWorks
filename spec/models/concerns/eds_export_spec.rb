# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EdsExport do
  let(:document) do
    EdsDocument.new(
      id: '123',
      eds_citation_exports: [{ 'id' => 'RIS', 'data' => 'TI  - CatZ N Bagelz' }]
    )
  end
  let(:empty_document) do
    EdsDocument.new(id: '456', eds_citation_exports: [])
  end

  describe '#eds_ris_export?' do
    it 'true when RIS citation is present' do
      expect(document.eds_ris_export?).to be true
    end

    it 'nil when RIS citation is not available' do
      expect(empty_document.eds_ris_export?).to be false
    end
  end

  describe '#export_as_ris' do
    it 'returns RIS data when RIS citation is present' do
      expect(document.export_as_ris).to eq 'TI  - CatZ N Bagelz'
    end
  end
end
