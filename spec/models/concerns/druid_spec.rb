require "spec_helper"

describe Druid do
  let(:document) { SolrDocument.new(url_fulltext: ["http://purl.stanford.edu/abc123"], url_suppl: ["http://stanford.edu/blah"]) }
  let(:another_document) { SolrDocument.new(url_fulltext: ["http://stanford.edu/blah"], url_suppl: ["http://purl.stanford.edu/abc123"]) }
  it "should return a druid from url_fulltext" do
    expect(document.druid).to eq "abc123"
  end
  it "should return a druid from the url_suppl" do
    expect(another_document.druid).to eq "abc123"
  end
end
