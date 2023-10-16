require 'rails_helper'

RSpec.describe "catalog/_index_mods_collection" do
  include ModsFixtures
  before do
    allow(view).to receive(:document).and_return(
      SolrDocument.new(
        id: 'abc123',
        modsxml: mods_everything,
        physical: ["The Physical Extent"],
        author_struct: [
          { 'link' => 'J. Smith', 'search' => '"J. Smith"', 'post_text' => '(Author)' },
          { 'link' => 'B. Smith', 'search' => '"B. Smith"', 'post_text' => '(Producer)' }
        ]
      )
    )
    render
  end

  it "should include a link to the contributor" do
    expect(rendered).to have_css('li', text: 'J. Smith')
  end

  it "should include the physical extent" do
    expect(rendered).to have_css("dt", text: "Description")
    expect(rendered).to have_css("dd", text: "The Physical Extent")
  end
end
