require 'rails_helper'

RSpec.describe "catalog/librarian_view" do
  include ModsFixtures
  include MarcMetadataFixtures
  describe "MARC records" do
    before do
      assign(:document, SolrDocument.new(
                          id: '12345',
                          last_updated: '2022-08-02T23:01:18Z',
                          marc_json_struct: metadata1,
                          holdings_json_struct: [{ "holdings_key" => "holdings_value" }],
                          folio_json_struct: [{ "folio_key" => "folio_value" }].to_json
                        ))
      render
    end

    it "renders the marc_view" do
      expect(rendered).to have_css('#marc_view')

      expect(rendered).to have_content('August  2, 2022  4:01pm')
      expect(rendered).to have_content('holdings_key')
      expect(rendered).to have_content('holdings_value')
      expect(rendered).to have_content('folio_key')
      expect(rendered).to have_content('folio_value')
    end
  end

  describe "MODS records" do
    before do
      assign(:document, SolrDocument.new(id: '12345', last_updated: '2022-08-02T23:01:18Z', modsxml: mods_everything))
      render
    end

    it "should render the mods_view" do
      expect(rendered).to have_content('August  2, 2022  4:01pm')
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
