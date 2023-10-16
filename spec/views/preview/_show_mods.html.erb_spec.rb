require 'rails_helper'

RSpec.describe "preview/_show_mods" do
  include ModsFixtures
  let(:presenter) { OpenStruct.new(heading: "Object Title") }
  let(:document) { SolrDocument.new(
    id: '123',
    collection: ['12345'],
    collection_with_title: ['12345 -|- Collection Title'],
    modsxml: mods_everything,
    file_id: ["123"],
    display_type: ["image"],
    item_display_struct: [
      { barcode: '123', library: 'GREEN', home_location: 'STACKS', callnumber: 'ABC 123' }
    ],
    isbn_display: [123],
    imprint_display: ["Imprint Statement"],
    author_struct: [
      { 'link' => 'J. Smith', 'search' => '"J. Smith"', 'post_text' => '(Author)' },
      { 'link' => 'B. Smith', 'search' => '"B. Smith"', 'post_text' => '(Producer)' }
    ],
    summary_display: ['Nunc venenatis et odio ac elementum. Nulla ornare faucibus laoreet']
  ) }

  before do
    expect(view).to receive(:document_presenter).and_return(presenter)
    assign(:document, document)
    render
  end

  it "should link to the contributor" do
    expect(rendered).to have_css("li a", text: "J. Smith")
  end

  it "should display the imprint" do
    expect(rendered).to have_css('li', text: "Imprint Statement")
  end

  it 'should display the digital collection' do
    expect(rendered).to have_css('dt', text: 'Digital collection')
    # Note: This is the object title because we're stubbing the presenter in this test
    expect(rendered).to have_css('dd a', text: 'Object Title')
  end

  it 'should display summary section' do
    expect(rendered).to have_css('dt', text: 'Summary')
    expect(rendered).to have_css('dd', text: /Nunc venenatis et odio ac elementum. Nulla ornare faucibus laoreet/)
  end

  it "should display library accordion section" do
    expect(rendered).to have_css('.accordion-section.location button.header', text: "Check availability")
    expect(rendered).to have_css('.accordion-section.location span.snippet', text: "Green Library")
    expect(rendered).to have_css('.accordion-section .details tbody tr', count: 2)
    expect(rendered).to have_css('.accordion-section .details tbody tr th', text: /Stacks/)
    expect(rendered).to have_css('.accordion-section .details tbody tr td', text: /ABC 123/)
  end
end
