# encoding: UTF-8

require 'rails_helper'

RSpec.describe "catalog/record/_mods_subjects" do
  include ModsFixtures

  describe "Object subjects" do
    let(:document) { SolrDocument.new(modsxml: mods_001) }
    let(:no_subjects_doc) { SolrDocument.new(modsxml: mods_file) }

    before do
      assign(:document, document)
    end

    it "should display subjects if available" do
      render
      expect(rendered).to have_css("dt", text: "Subject")
      expect(rendered).to have_css("a", text: '1906 Earthquake')
    end
    it "should should not render anything when a document has no subjects" do
      assign(:document, no_subjects_doc)
      render
      expect(rendered).not_to be_present
    end
  end

  describe "Object genres" do
    let(:document) { SolrDocument.new(modsxml: mods_001) }
    let(:no_genres_doc) { SolrDocument.new(modsxml: mods_file) }

    before do
      assign(:document, document)
    end

    it "should display genres if available" do
      render
      expect(rendered).to have_css("dt", text: "Genre")
      expect(rendered).to have_css("a", text: 'Photographs')
    end
    it "should should not render anything when a document has no genres" do
      assign(:document, no_genres_doc)
      render
      expect(rendered).not_to be_present
    end
  end
end
