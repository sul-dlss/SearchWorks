# encoding: UTF-8
require "spec_helper"

describe "catalog/record/_mods_subjects.html.erb" do
  include ModsFixtures

  describe "Object subjects" do
    let(:document) { SolrDocument.new(modsxml: mods_001) }
    before do
      assign(:document, document)
    end
    it "should display subjects if available" do
      render
      expect(rendered).to eq "        1906 Earthquake\n"
    end
  end
end
