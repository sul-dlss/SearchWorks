require 'spec_helper'

class IndexLinksTestClass
  include IndexLinks
end

describe IndexLinks do
  let(:solr_document) {
    SolrDocument.new(
      url_fulltext:   ["http://library.stanford.edu"],
      url_suppl:      ["http://searchworks.stanford.edu"],
      url_restricted: ["http://library.stanford.edu"]
    )
  }
  let(:finding_aid_document) {
    SolrDocument.new(
      url_suppl: ["http://oac.cdlib.org/findaid/something-else"]
    )
  }
  let(:sfx_document) {
    SolrDocument.new(
      url_sfx: ['http://example.com/sfx-link']
    )
  }
  let(:bad_url_document) {
    SolrDocument.new(
      url_fulltext: ["http://www.example.com/lookup?^The+Query+Is+No+Good"]
    )
  }
  describe "mixin" do
    it "should add the #index_links method" do
      expect(solr_document).to respond_to(:index_links)
    end
    it "#index_links should return SearchWorks::Links" do
      expect(solr_document.index_links).to be_a_kind_of(SearchWorks::Links)
      solr_document.index_links.each do |index_link|
        expect(index_link).to be_a_kind_of SearchWorks::Links::Link
      end
    end
  end
  describe "SearchWorks::Links" do
    let(:index_links) {solr_document.index_links}
    let(:finding_aid_links) {finding_aid_document.index_links}
    let(:sfx_links) { sfx_document.index_links }
    let(:bad_links) { bad_url_document.index_links }
    it "should return both fulltext and supplemental links" do
      expect(index_links.all.length).to eq 2
      expect(index_links.all.first.text).to match /^<a.*>library\.stanford\.edu<\/a>$/
      expect(index_links.all.last.text).to match  /^<a.*>searchworks\.stanford\.edu<\/a>$/
    end
    it "should identify urls that are in the url_restricted field as stanford only" do
      expect(index_links.all.first).to    be_stanford_only
      expect(index_links.all.last).to_not be_stanford_only
    end
    it "should identify urls that are in the url_fulltext field as fulltext" do
      expect(index_links.all.first).to    be_fulltext
      expect(index_links.all.last).to_not be_fulltext
    end
    it "should identify finding aid links" do
      expect(finding_aid_links.all.first).to be_finding_aid
      expect(finding_aid_links.finding_aid.length).to eq 1
      expect(finding_aid_links.finding_aid.first.text).to match /<a href='.*oac\.cdlib\.org\/findaid\/something-else'>Online Archive of California<\/a>/
    end
    it "should parse bad links properly" do
      expect(bad_links.all.length).to eq 1
      expect(bad_links.all.first.text).to match /<a href=.*example\.com\/lookup\?\^The\+Query.*>www\.example\.com<\/a>/
    end
    it "should identify sfx URLs and link them appropriately" do
      expect(sfx_links.all.length).to eq 1
      expect(sfx_links.all.first).to be_sfx
      expect(sfx_links.sfx.length).to eq 1
      expect(sfx_links.sfx.first).to be_sfx
      expect(sfx_links.sfx.first.text).to match /^<a href=.*class='sfx'>Find full text<\/a>$/
    end
  end
end
