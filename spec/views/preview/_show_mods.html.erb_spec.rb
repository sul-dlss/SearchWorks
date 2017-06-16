require "spec_helper"

describe "preview/_show_mods.html.erb" do
  include ModsFixtures
  let(:presenter) { instance_double(Blacklight::DocumentPresenter, document_heading: "Object Title") }
  let(:document) { SolrDocument.new(
    id: '123',
    collection: ['12345'],
    collection_with_title: ['12345 -|- Collection Title'],
    modsxml: mods_everything,
    file_id: ["123"],
    display_type: ["image"],
    item_display: [ "123 -|- GREEN -|- STACKS -|- -|- -|- -|- -|- -|- ABC 123" ],
    isbn_display: [ 123 ],
    imprint_display: ["Imprint Statement"]
  ) }

  before do
    expect(view).to receive(:presenter).and_return(presenter)
    assign(:document, document)
    render
  end

  it "should link to the contributor" do
    expect(rendered).to have_css("li a", text: "J. Smith")
  end

  it "should display the imprint" do
    expect(rendered).to have_css('li', text: "Imprint Statement")
  end

  it 'should display the collection' do
    expect(rendered).to have_css('dt', text: 'Collection')
    # Note: This is the object title because we're stubbing the presenter in this test
    expect(rendered).to have_css('dd a', text: 'Object Title')
  end

  it "should display summary accordion section" do
    expect(rendered).to have_css('.accordion-section.summary button.header', text: "Summary")
    expect(rendered).to have_css('.accordion-section.summary .snippet', text: /Nunc venenatis et odio ac elementum. Nulla ornare faucibus laoreet/)
    expect(rendered).to have_css('.accordion-section.summary .details', text: "Nunc venenatis et odio ac elementum. Nulla ornare faucibus laoreet")
  end

  it "should display library accordion section" do
    expect(rendered).to have_css('.accordion-section.location button.header', text: "Check availability")
    expect(rendered).to have_css('.accordion-section.location span.snippet', text: "Green Library")
    expect(rendered).to have_css('.accordion-section .details tbody tr', count: 2)
    expect(rendered).to have_css('.accordion-section .details tbody tr th', text: /Stacks/)
    expect(rendered).to have_css('.accordion-section .details tbody tr td', text: /ABC 123/)
  end

  it "should display online accordion section" do
    expect(rendered).to have_css('.accordion-section.online button.header', text: "Online")
    expect(rendered).to have_css('.details a', text: "Google Books (Full view)")
  end


end
