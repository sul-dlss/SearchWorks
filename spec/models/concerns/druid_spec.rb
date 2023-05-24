require "spec_helper"

describe Druid do
  let(:explicit_druid) do
    SolrDocument.new(
      druid: "321cba",
      marc_links_struct: [{ href: "https://purl.stanford.edu/abc123", fulltext: true }]
    )
  end

  let(:document) do
    SolrDocument.new(
      marc_links_struct: [{ href: "https://purl.stanford.edu/abc123", fulltext: true },
                          { href: "https://stanford.edu/blah" }]
    )
  end

  let(:another_document) do
    SolrDocument.new(
      marc_links_struct: [{ href: "https://stanford.edu/blah", fulltext: true },
                          { href: "https://purl.stanford.edu/abc123" }]
    )
  end

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
