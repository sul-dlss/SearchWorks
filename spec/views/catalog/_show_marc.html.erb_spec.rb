# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/_show_marc' do
  include MarcMetadataFixtures
  before do
    allow(view).to receive_messages(add_purl_embed_header: '', render_cover_image: '')
    render 'catalog/show_marc', document:
  end

  context 'when a document has a managed purl' do
    let(:document) {
      SolrDocument.new(id: '123', marc_json_struct: managed_purl_fixture, marc_links_struct: [{ link_text: 'Some Part Label', managed_purl: true }, { managed_purl: true }])
    }

    it 'includes the managed purl panel and upper metadata elements' do
      expect(rendered).to have_css('.managed-purl-panel')
      expect(rendered).to have_css('.upper-record-metadata')
      expect(rendered).to have_css('li', text: 'Some Part Label')
      expect(rendered).to have_css('li', text: 'part 2')
    end
  end
end
