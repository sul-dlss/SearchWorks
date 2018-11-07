require 'spec_helper'

describe 'catalog/_show_marc.html.erb' do
  include MarcMetadataFixtures
  before do
    allow(view).to receive(:add_purl_embed_header).and_return('')
    allow(view).to receive(:render_cover_image).and_return('')
    assign(:document, document)
    render
  end

  context 'when a document has a managed purl' do
    let(:document) { SolrDocument.new(id: '123', marcxml: managed_purl_fixture, marc_links_struct: [{ text: 'Some Part Label', managed_purl: true }, { managed_purl: true }]) }
    it 'includes the managed purl panel and upper metadata elements' do
      expect(rendered).to have_css('.managed-purl-panel')
      expect(rendered).to have_css('.upper-record-metadata')
      expect(rendered).to have_css('li', text: 'Some Part Label')
      expect(rendered).to have_css('li', text: 'part 2')
    end
  end
end
