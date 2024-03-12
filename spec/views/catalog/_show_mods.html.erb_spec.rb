# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/_show_mods' do
  include ModsFixtures
  let(:document) { SolrDocument.new(modsxml: mods_001) }

  before do
    allow(view).to receive(:add_purl_embed_header).and_return('')
    render 'catalog/show_mods', document:
  end

  context 'when a document has a druid' do
    context 'there is published content' do
      let(:document) do
        SolrDocument.new(druid: 'abc123', dor_resource_count_isi: 1, modsxml: mods_001)
      end

      it 'includes the purl-embed-viewer element' do
        expect(rendered).to have_css('.purl-embed-viewer')
      end
    end

    context 'there is no published content' do
      let(:document) do
        SolrDocument.new(druid: 'abc123', dor_resource_count_isi: 0, modsxml: mods_001)
      end

      it 'does not include the purl-embed-viewer element' do
        expect(rendered).to have_no_css('.purl-embed-viewer')
      end
    end

    context 'dor_resource_count_isi is not defined' do
      let(:document) { SolrDocument.new(druid: 'abc123', modsxml: mods_001) }

      it 'includes the purl-embed-viewer element' do
        expect(rendered).to have_css('.purl-embed-viewer')
      end
    end

    context 'with a iiif manifest' do
      let(:document) do
        SolrDocument.new(druid: 'abc123', modsxml: mods_001, iiif_manifest_url_ssim: ['example.com'])
      end

      it 'includes IIIF Drag n Drop link' do
        expect(rendered).to have_css 'a.iiif-dnd[href="https://library.stanford.edu/projects/international-image-interoperability-framework/viewers?manifest=example.com"]'
      end
    end
  end

  context 'when a document does not have a druid' do
    it 'does not include the purl-embed-viewer element' do
      expect(rendered).to have_no_css('.purl-embed-viewer')
    end
  end
end
