require "spec_helper"

describe "catalog/librarian_view" do
  include ModsFixtures
  include MarcMetadataFixtures
  describe "MARC records" do
    before do
      assign(:document, SolrDocument.new(id: '12345', last_updated: '2022-08-01T23:01:18Z', marcxml: metadata1))
      render
    end

    it "should render the marc_view" do
      expect(rendered).to have_content('August  1, 2022 11:01pm')
      expect(rendered).to have_css('#marc_view')
    end
  end

  describe "MODS records" do
    before do
      assign(:document, SolrDocument.new(id: '12345', last_updated: '2022-08-01T23:01:18Z', modsxml: mods_everything))
      render
    end

    it "should render the mods_view" do
      expect(rendered).to have_content('August  1, 2022 11:01pm')
      expect(rendered).to have_css('.mods-view')
    end
  end

  describe "records w/o raw metadata" do
    before do
      assign(:document, SolrDocument.new(id: '12345'))
      render
    end

    it "should indicate there is no librarian view" do
      expect(rendered).to have_content('No librarian view available')
    end
  end
end
