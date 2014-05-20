require "spec_helper"

describe SearchWorks::Links do
  let(:links) { SearchWorks::Links.new({}) }
  before do
    links.stub(:all).and_return([
      OpenStruct.new(text: "non-fulltext link", fulltext?: false),
      OpenStruct.new(text: "fulltext link",     fulltext?: true)
    ])
  end
  it "should identify fulltext links" do
    expect(links.fulltext.length).to eq 1
    expect(links.fulltext.first.text).to eq "fulltext link"
  end
  it "should identify supplemental links" do
    expect(links.supplemental.length).to eq 1
    expect(links.supplemental.first.text).to eq "non-fulltext link"
  end
  describe "Link" do
    let(:link) { SearchWorks::Links::Link.new(text: "text", fulltext: true, stanford_only: true) }
    it "should parse the text option" do
      expect(link.text).to eq "text"
    end
    it "should parse the fulltext option" do
      expect(link).to be_fulltext
    end
    it "should parse the stanford only option" do
      expect(link).to be_stanford_only
    end
  end
end
