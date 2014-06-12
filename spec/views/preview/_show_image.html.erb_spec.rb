require "spec_helper"

describe "preview/_show_image.html.erb" do
  include ModsFixtures

  let(:document) { SolrDocument.new(modsxml: mods_everything, file_id: ["123"], display_type: ["image"]) }
  before do
    assign(:document, document)
  end
  it "should include the type of resource" do
    render
    expect(rendered).to have_css("img.preview-img")
    expect(rendered).to have_css("dt", text: "Type of resource")
    expect(rendered).to have_css("dd", text: "Still image")
  end
end
