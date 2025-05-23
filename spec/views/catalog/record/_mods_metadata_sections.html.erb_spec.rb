# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "catalog/record/_mods_metadata_sections" do
  include ModsFixtures

  before do
    render 'catalog/record/mods_metadata_sections', document:
  end

  context "when metadata sections are all available" do
    let(:document) { SolrDocument.new(modsxml: mods_001) }

    it "displays correct sections" do
      expect(rendered).to have_css('h3', text: "Contributors")
      expect(rendered).to have_css('h3', text: "Abstract/Contents")
      expect(rendered).to have_css('h3', text: "Subjects")
      expect(rendered).to have_css('h3', text: "Bibliographic information")
      expect(rendered).to have_css('h3', text: "Access conditions")
    end
  end

  context "when no metadata sections are available" do
    let(:document) { SolrDocument.new(modsxml: mods_only_title) }

    it "displays correct sections" do
      expect(rendered).to have_no_css('h3', text: "Abstract/Contents")
      expect(rendered).to have_no_css('h3', text: "Subjects")
      expect(rendered).to have_no_css('h3', text: "Access conditions")
    end
  end
end
