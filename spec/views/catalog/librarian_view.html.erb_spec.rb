require "spec_helper"

describe "catalog/librarian_view" do
  include ModsFixtures
  include MarcMetadataFixtures
  describe "MARC records" do
    before do
      assign(:document, SolrDocument.new(
                          id: '12345',
                          last_updated: '2022-08-01T23:01:18Z',
                          marcxml: metadata1,
                          holdings_json_struct: [{ "holdings_key" => "holdings_value" }].to_json,
                          folio_json_struct: [{ "folio_key" => "folio_value" }].to_json
                        ))
      render
    end

    it "should render the marc_view" do
      expect(rendered).to have_css('#marc_view')
      expect(rendered).to have_css('#folio-json-view')

      expect(rendered).to have_content('August  1, 2022 11:01pm')
      expect(rendered).to have_content('holdings_key')
      expect(rendered).to have_content('holdings_value')
      expect(rendered).to have_content('folio_key')
      expect(rendered).to have_content('folio_value')
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
