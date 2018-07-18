require 'spec_helper'

describe BlacklightHelper do
  describe "#document_partial_name" do
    let(:marc) { SolrDocument.new(marcxml: '<xml />') }
    let(:mods) { SolrDocument.new(modsxml: '<xml />') }
    let(:no_display_type) { SolrDocument.new }
    let(:blacklight_config) { Blacklight::Configuration.new }
    it "should use the #display_type when available" do
      expect(document_partial_name(marc)).to eq "marc"
      expect(document_partial_name(mods)).to eq "mods"
    end
    it "should fall back on the default when their is no display type" do
      expect(document_partial_name(no_display_type)).to eq "default"
    end
  end
end
