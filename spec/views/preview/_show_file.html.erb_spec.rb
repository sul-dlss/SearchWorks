require "spec_helper"

describe "preview/_show_file.html.erb" do
  include ModsFixtures
  let(:presenter) { OpenStruct.new(document_heading: "Collection Title") }
  let(:document) { SolrDocument.new(
    id: '123',
    collection: ['12345'],
    collection_with_title: ['12345 -|- Collection Title'],
    modsxml: mods_file,
    item_display: [ "123 -|- GREEN -|- STACKS -|- -|- -|- -|- -|- -|- ABC 123" ],
    isbn_display: [ 123 ],
    imprint_display: ["Imprint Statement"]

  ) }

  before do
    expect(view).to receive(:presenter).and_return(presenter)
    assign(:document, document)
    render
  end

  it "should link the author" do
    expect(rendered).to have_css("li a", text: "J. Smith")
  end

  it "should display the imprint" do
    expect(rendered).to have_css('li', text: "Imprint Statement")
  end

  it "should display the collection" do
    expect(rendered).to have_css('dt', "Collection")
    expect(rendered).to have_css('dd', "Collection Title")
  end

  it "should display summary accordion section" do
    expect(rendered).to have_css('.accordion-section.summary a.header', text: "Summary")
    expect(rendered).to have_css('.accordion-section.summary .snippet', text: /Nunc venenatis et odio ac elementum. Nulla ornare faucibus laoreet/)
    expect(rendered).to have_css('.accordion-section.summary .details', text: "Nunc venenatis et odio ac elementum. Nulla ornare faucibus laoreet")
  end

  it "should display library accordion section" do
    expect(rendered).to have_css('.accordion-section.location a.header', text: "At the library")
    expect(rendered).to have_css('.accordion-section.location span.snippet', text: "Green Library")
    expect(rendered).to have_css('.accordion-section .details tbody tr', count: 2)
    expect(rendered).to have_css('.accordion-section .details tbody tr th', text: /Stacks/)
    expect(rendered).to have_css('.accordion-section .details tbody tr td', text: /ABC 123/)
  end

  it "should display online accordion section" do
    expect(rendered).to have_css('.accordion-section.online a.header', text: "Online")
    expect(rendered).to have_css('.details a', text: "Google Books (Full view)")
  end

end
