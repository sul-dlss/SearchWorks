require 'rails_helper'

RSpec.describe "catalog/record/_mods_upper_metadata_items" do
  include ModsFixtures

  let(:document) { SolrDocument.new(modsxml: mods_everything) }

  before do
    render 'catalog/record/mods_upper_metadata_items', document:
  end

  it "displays fields" do
    expect(rendered).to have_css("dt", text: "Type of resource")
    expect(rendered).to have_css("dd", text: "still image")

    expect(rendered).to have_css("dt", text: "Imprint")
    expect(rendered).to have_css("dd", text: "copyright 2014")

    expect(rendered).to have_css("dt", text: "Condition")
    expect(rendered).to have_css("dd", text: "amazing")
  end
end
