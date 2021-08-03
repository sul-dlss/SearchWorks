# encoding: UTF-8

require "spec_helper"

describe "catalog/record/_mods_abstract_contents.html.erb" do
  include ModsFixtures

  describe "Object abstract/contents" do
    let(:document) { SolrDocument.new(modsxml: mods_001) }

    before do
      assign(:document, document)
    end

    it "should display abstract" do
      render
      expect(rendered).to have_css("dd.section-abstract", text: "Topographical and street map of the")
      expect(rendered).to have_css("dd.section-contents", text: "This is an amazing table of contents!")
    end
  end
end
