# encoding: UTF-8

require "spec_helper"

describe "catalog/record/_mods_access" do
  include ModsFixtures

  describe "Object access" do
    let(:document) { SolrDocument.new(modsxml: mods_001) }

    before do
      assign(:document, document)
    end

    it "should display access" do
      render
      expect(rendered).to have_css("dt", text: "Use and reproduction")
      expect(rendered).to have_css("dd", text: "Copyright © Stanford University.")
    end
  end
end
