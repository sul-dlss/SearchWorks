require "spec_helper"

describe "preview/_show_image.html.erb" do
  include ModsFixtures

  let(:document) { SolrDocument.new(
    modsxml: mods_everything,
    file_id: ["123"],
    display_type: ["image"],
    summary_display: [ "Nunc venenatis et odio ac elementum. Nulla ornare faucibus laoreet" ],
    item_display: [ "123 -|- GREEN -|- STACKS -|- -|- -|- -|- -|- -|- ABC 123" ],
    isbn_display: [ 123 ]
  ) }

  before do
    assign(:document, document)
    render
  end

  it "should include the type of resource" do
    expect(rendered).to have_css("img.preview-img")
    expect(rendered).to have_css("dt", text: "Type of resource")
    expect(rendered).to have_css("dd", text: "Still image")
  end

  it "should display uppermetadata section" do
    expect(rendered).to have_css("dl dt", text: "Author/Creator")
    expect(rendered).to have_css("dl dd", text: "J. Smith")
  end

  it "should display summary accordion section" do
    expect(rendered).to have_css('.accordion-section.summary a.header', text: "Summary")
    expect(rendered).to have_css('.accordion-section.summary span.snippet', text: /Nunc venenatis et odio ac elementum. Nulla ornare faucibus laoreet/)
    expect(rendered).to have_css('.accordion-section.summary div.details', text: "Nunc venenatis et odio ac elementum. Nulla ornare faucibus laoreet")
  end

  it "should display library accordion section" do
    expect(rendered).to have_css('.accordion-section.location a.header', text: "At the library")
    expect(rendered).to have_css('.accordion-section.location span.snippet', text: "Green Library")
    expect(rendered).to have_css('.accordion-section .details tbody tr', count: 1)
    expect(rendered).to have_css('.accordion-section .details tbody tr td', text: /Stacks\s*:\s*ABC 123/)
  end

  it "should display online accordion section" do
    expect(rendered).to have_css('.accordion-section.online a.header', text: "Online")
    expect(rendered).to have_css('.details a', text: "Google Books Full view")
  end


end
