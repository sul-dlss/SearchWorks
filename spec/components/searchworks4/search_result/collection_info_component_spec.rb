# frozen_string_literal: true

require "rails_helper"

RSpec.describe Searchworks4::SearchResult::CollectionInfoComponent, type: :component do
  before do
    render_inline(described_class.new(collection:))
  end

  let(:collection) { SolrDocument.from_fixture('11966809.yml') }

  it "renders the collection information" do
    expect(page).to have_css '.superhead', text: 'Collection'
    expect(page).to have_text 'SFO Travel Ban Protest poster collection'
    expect(page).to have_link 'Collection details', href: "/view/#{collection.id}"
  end
end
