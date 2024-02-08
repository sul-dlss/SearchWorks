require 'rails_helper'

RSpec.describe SearchResult::Item::Mods::MetadataComponent, type: :component do
  include ModsFixtures

  let(:component) { described_class.new(document:) }

  let(:document) do
    SolrDocument.new(
      collection: ['12345'],
      collection_with_title: ['12345 -|- Collection Title'],
      modsxml: mods_everything,
      physical: ["The Physical Extent"],
      imprint_display: ["Imprint Statement"],
      summary_display: ['Nunc venenatis et odio ac elementum. Nulla ornare faucibus laoreet'],
      author_struct: [
        { 'link' => 'J. Smith', 'search' => '"J. Smith"', 'post_text' => '(Author)' },
        { 'link' => 'B. Smith', 'search' => '"B. Smith"', 'post_text' => '(Producer)' }
      ]
    )
  end

  subject(:page) { render_inline(component) }

  it "renders the metadata" do
    expect(page).to have_css('li', text: "Imprint Statement")

    expect(page).to have_css('li a', text: 'J. Smith')

    expect(page).to have_css("dt", text: "Description")
    expect(page).to have_css("dd", text: "The Physical Extent")

    expect(page).to have_css('dt', text: 'Digital collection')

    expect(page).to have_css('dt', text: 'Summary')
    expect(page).to have_css('dd', text: /Nunc venenatis et odio ac elementum/)
  end
end
