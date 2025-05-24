# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "catalog/record/_marc_metadata_sections" do
  include MarcMetadataFixtures

  describe "Metadata sections all available" do
    let(:document) {
      SolrDocument.new(marc_json_struct: marc_sections_fixture, author_struct: [{ creator: [{ link: '...', search: '...' }] }], marc_links_struct: [{ material_type: 'finding aid' }])
    }

    before do
      render 'catalog/record/marc_metadata_sections', document:
    end

    it "displays correct sections" do
      expect(rendered).to have_css('h3', text: "Contributors")
      expect(rendered).to have_css('h3', text: "Contents/Summary")
      expect(rendered).to have_css('h3', text: "Bibliographic information")
    end
  end
end
