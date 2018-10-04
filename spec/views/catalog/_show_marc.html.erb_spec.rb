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
    let(:document) { SolrDocument.new(id: '123', marcxml: managed_purl_fixture, managed_purl_urls: ['http://purl.stanford.edu/gg853cy1667', 'http://purl.stanford.edu/rw779rf3064']) }
    it 'includes the managed purl panel and upper metadata elements' do
      expect(rendered).to have_css('.managed-purl-panel')
      expect(rendered).to have_css('.upper-record-metadata')
    end
  end
end
