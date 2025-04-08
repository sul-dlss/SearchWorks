# frozen_string_literal: true

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

  describe '#eds_ris_export?' do
    it 'true when RIS citation is present' do
      expect(document.eds_ris_export?).to be true
    end

    it 'nil when RIS citation is not available' do
      expect(empty_document.eds_ris_export?).to be false
    end
  end

  describe '#export_as_ris' do
    it 'returns RIS solr data when RIS citation is present' do
      expect(document.export_as_ris).to eq 'TI  - CatZ N Bagelz'
    end

    it 'returns computed ris when solr RIS citation is not available' do
      expect(empty_document.export_as_ris).to eq "TY  - GEN\n" \
                                                 "DP  - https://searchworks.stanford.edu/view/456\n" \
                                                 "UR  - https://searchworks.stanford.edu/view/456\nER  - "
    end
  end
end
