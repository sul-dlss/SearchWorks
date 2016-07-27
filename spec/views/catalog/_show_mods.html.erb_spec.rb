require 'spec_helper'

describe 'catalog/_show_mods.html.erb' do
  include ModsFixtures
  let(:document) { SolrDocument.new(modsxml: mods_001) }
  before do
    allow(view).to receive(:add_purl_embed_header).and_return('')
    assign(:document, document)
    render
  end

  context 'when a document has a druid' do
    let(:document) { SolrDocument.new(druid: 'abc123', modsxml: mods_001) }
    it 'includes the purl-embed-viewer element' do
      expect(rendered).to have_css('.purl-embed-viewer')
    end
  end

  context 'when a document does not have a druid' do
    it 'does not include the purl-embed-viewer element' do
      expect(rendered).not_to have_css('.purl-embed-viewer')
    end
  end
end
