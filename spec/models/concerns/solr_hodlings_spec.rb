require "spec_helper"

describe SolrHoldings do
  let(:document) { SolrDocument.new }
  it "should provide a holdings method" do
    expect(document).to respond_to(:holdings)
    expect(document.holdings).to be_a Holdings
  end
end
