require "spec_helper"

describe "catalog/_tech_details.html.erb" do
  include ModsFixtures
  include MarcMetadataFixtures
  describe "for MARC records" do
    before do
      assign(:document, SolrDocument.new(id: '12345', marcxml: metadata1))
      render
    end
    it "should include the Catkey" do
      expect(rendered).to have_content("Catkey: 12345")
    end
    it "should include a link to the librarian view" do
      expect(rendered).to have_css('a', text: "Librarian view")
    end
  end
  describe "for MODS records" do
    before do
      assign(:document, SolrDocument.new(id: '12345', modsxml: mods_everything))
      render
    end
    it "should include the DRUID" do
      expect(rendered).to have_content("DRUID: 12345")
    end
    it "should include a link to the librarian view" do
      expect(rendered).to have_css('a', text: "Librarian view")
    end
  end
  describe "for records w/o raw metadata" do
    before do
      assign(:document, SolrDocument.new(id: '12345'))
      render
    end
    it "should include the ID" do
      expect(rendered).to have_content("ID: 12345")
    end
    it "should include a link to the librarian view" do
      expect(rendered).not_to have_content("Librarian view")
    end
  end
end
