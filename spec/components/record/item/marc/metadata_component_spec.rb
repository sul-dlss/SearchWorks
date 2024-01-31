require 'rails_helper'

RSpec.describe Record::Item::Marc::MetadataComponent, type: :component do
  include MarcMetadataFixtures

  let(:component) { described_class.new(document:) }

  let(:document) do
    SolrDocument.new(id: '123', marc_json_struct: managed_purl_fixture,
                     marc_links_struct: [
                       { link_text: 'Some Part Label', managed_purl: true },
                       { managed_purl: true }
                     ])
  end

  subject(:page) { render_inline(component) }

  it 'includes the managed purl panel and upper metadata elements' do
    expect(page).to have_css('.managed-purl-panel')
    expect(page).to have_css('.upper-record-metadata')
    expect(page).to have_css('li', text: 'Some Part Label')
    expect(page).to have_css('li', text: 'part 2')
  end
end
