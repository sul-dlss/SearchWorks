require 'rails_helper'

RSpec.describe SearchResult::Collection::Mods::MetadataComponent, type: :component do
  include ModsFixtures

  let(:component) { described_class.new(document:) }

  let(:document) do
    SolrDocument.new(
      id: 'abc123',
      modsxml: mods_everything,
      physical: ["The Physical Extent"],
      author_struct: [
        { 'link' => 'J. Smith', 'search' => '"J. Smith"', 'post_text' => '(Author)' },
        { 'link' => 'B. Smith', 'search' => '"B. Smith"', 'post_text' => '(Producer)' }
      ]
    )
  end

  subject(:page) { render_inline(component) }

  it "renders the metadata" do
    expect(page).to have_css('li', text: 'J. Smith')

    expect(page).to have_css("dt", text: "Description")
    expect(page).to have_css("dd", text: "The Physical Extent")
  end
end
