require "spec_helper"

describe Druid do
  let(:explicit_druid) { SolrDocument.new(druid: "321cba", url_fulltext: ["https://purl.stanford.edu/abc123"]) }
  let(:document) { SolrDocument.new(url_fulltext: ["https://purl.stanford.edu/abc123"], url_suppl: ["https://stanford.edu/blah"]) }
  let(:another_document) { SolrDocument.new(url_fulltext: ["https://stanford.edu/blah"], url_suppl: ["https://purl.stanford.edu/abc123"]) }
  it "should return the druid from the druid field if available" do
    expect(explicit_druid.druid).to eq "321cba"
  end
  it "should return a druid from url_fulltext" do
    expect(document.druid).to eq "abc123"
  end
  it "should return a druid from the url_suppl" do
    expect(another_document.druid).to eq "abc123"
  end
end
