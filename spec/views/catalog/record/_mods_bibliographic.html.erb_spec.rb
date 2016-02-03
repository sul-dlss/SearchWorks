# encoding: UTF-8
require "spec_helper"

describe "catalog/record/_mods_bibliographic.html.erb" do
  include ModsFixtures

  describe "Object bibliographic" do
    let(:document) { SolrDocument.new(modsxml: mods_everything) }
    before do
      assign(:document, document)
    end
    it "should display audience" do
      render
      expect(rendered).to have_css("dt", text: "Who?")
      expect(rendered).to have_css("dd", text: "Cat loverz")
    end
    it "should display notes" do
      render
      expect(rendered).to have_css("dt", text: "Note")
      expect(rendered).to have_css("dd", text: "Pick up milk")
      expect(rendered).to have_css("dt", text: "Notez")
      expect(rendered).to have_css("dd", text: "Pick up milkz")
    end
    skip "should display related item" do
      # render
      # expect(rendered).to have_css("dt", text: "Related")
      # expect(rendered).to have_css("dd", text: "Cat loverz")
    end
    it "should display identifier" do
      render
      expect(rendered).to have_css("dt", text: "uri")
      expect(rendered).to have_css("dd", text: "http://www.myspace.com/myband")
    end
    it "should display location" do
      render
      expect(rendered).to have_css("dt", text: "Secret Location")
      expect(rendered).to have_css("dd", text: "NorCal")
    end
  end
end
