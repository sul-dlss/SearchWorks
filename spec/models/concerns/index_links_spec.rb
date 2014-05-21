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
  end
end
