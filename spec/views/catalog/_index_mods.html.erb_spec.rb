require 'rails_helper'

RSpec.describe "catalog/_index_mods" do
  include ModsFixtures
  let(:presenter) { OpenStruct.new(heading: "Object Title") }

  before do
    allow(view).to receive_messages(document: SolrDocument.new(
      collection: ['12345'],
      collection_with_title: ['12345 -|- Collection Title'],
      modsxml: mods_everything,
      physical: ["The Physical Extent"],
      imprint_display: ["Imprint Statement"],
      author_struct: [
        { 'link' => 'J. Smith', 'search' => '"J. Smith"', 'post_text' => '(Author)' },
        { 'link' => 'B. Smith', 'search' => '"B. Smith"', 'post_text' => '(Producer)' }
      ]
    ), blacklight_config: Blacklight::Configuration.new)
    expect(view).to receive(:document_presenter).and_return(presenter)
    render
  end

  it "should include the imprint" do
    expect(rendered).to have_css('li', text: "Imprint Statement")
  end
  it "should include the first contributor" do
    expect(rendered).to have_css('li a', text: 'J. Smith')
  end
  it "should include the physical extent" do
    expect(rendered).to have_css("dt", text: "Description")
    expect(rendered).to have_css("dd", text: "The Physical Extent")
  end
  it "should include the digital collection" do
    expect(rendered).to have_css('dt', text: 'Digital collection')
  end

  it 'should include the summary' do
    expect(rendered).to have_css('dt', text: 'Summary')
    expect(rendered).to have_css('dd', text: /Nunc venenatis et odio ac elementum/)
  end
end
