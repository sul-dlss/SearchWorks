require "spec_helper"

describe SearchWorks::Links do
  let(:links) { SearchWorks::Links.new({}) }
  before do
    links.stub(:all).and_return([
      OpenStruct.new(html: "non-fulltext link", fulltext?: false),
      OpenStruct.new(html: "fulltext link",     fulltext?: true),
      OpenStruct.new(html: "1st finding aid link", fulltext?: true,  finding_aid?: true),
      OpenStruct.new(html: "2nd finding aid link", fulltext?: false, finding_aid?: true)
    ])
  end
  it "should identify fulltext links" do
    expect(links.fulltext.length).to eq 1
    expect(links.fulltext.first.html).to eq "fulltext link"
  end
  it "should identify supplemental links" do
    expect(links.supplemental.length).to eq 1
    expect(links.supplemental.first.html).to eq "non-fulltext link"
  end
  it "should identify finding aid links" do
    expect(links.finding_aid.length).to eq 2
    expect(links.finding_aid.first.html).to eq "1st finding aid link"
    expect(links.finding_aid.last.html).to eq "2nd finding aid link"
  end
  describe "Link" do
    let(:link) { SearchWorks::Links::Link.new(html: "text", fulltext: true, stanford_only: true, finding_aid: true, sfx: true) }
    it "should parse the text option" do
      expect(link.html).to eq "text"
    end
    it "should parse the fulltext option" do
      expect(link).to be_fulltext
    end
    it "should parse the stanford only option" do
      expect(link).to be_stanford_only
    end
    it "should parse the finding_aid option" do
      expect(link).to be_finding_aid
    end
    it "should parse the sfx option" do
      expect(link).to be_sfx
    end
  end
end
