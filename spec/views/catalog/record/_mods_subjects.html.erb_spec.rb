# encoding: UTF-8
require "spec_helper"

describe "catalog/record/_mods_subjects.html.erb" do
  include ModsFixtures

  describe "Object subjects" do
    let(:document) { SolrDocument.new(modsxml: mods_001) }
    let(:no_subjects_doc) { SolrDocument.new(modsxml: mods_file) }
    before do
      assign(:document, document)
    end
    it "should display subjects if available" do
      render
      expect(rendered).to have_css("a", text: '1906 Earthquake')
    end
    it "should should not render anything when a document has no subjects" do
      assign(:document, no_subjects_doc)
      render
      expect(rendered).to_not be_present
    end
  end
end
