# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Record::MarcDocumentComponent, type: :component do
  include MarcMetadataFixtures

  subject(:page) { render_inline(component) }

  let(:component) { described_class.new(document: ShowDocumentPresenter.new(document, view_context)) }
  let(:view_context) { ActionController::Base.helpers }
  let(:document) do
    SolrDocument.new(id: '123', marc_json_struct: managed_purl_fixture,
                     marc_links_struct: [
                       { link_text: 'Some Part Label', managed_purl: true },
                       { managed_purl: true }
                     ])
  end

  before do
    allow(view_context).to receive_messages(blacklight_config: CatalogController.blacklight_config, action_name: 'show')
  end

  it 'includes the managed purl panel and upper metadata elements' do
    expect(page).to have_css('.managed-purl-panel')
    expect(page).to have_css('.upper-record-metadata')
    expect(page).to have_css('li', text: 'Some Part Label')
    expect(page).to have_css('li', text: 'part 2')
  end
end
