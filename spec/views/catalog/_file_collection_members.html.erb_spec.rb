require "spec_helper"

describe "catalog/_file_collection_members.html.erb" do
  let(:document) { SolrDocument.new() }
  let(:collection_members) { [
    SolrDocument.new(id: 1, pub_date: "2010", author_person_full_display: "Mr. Bean"),
    SolrDocument.new(id: 2, pub_date: "2011")
  ] }
  before do
    collection_members.stub(:total).and_return('10')
    assign(:document, document)
    view.stub(:presenter).and_return(OpenStruct.new(document_heading: "File Item"))
    expect(document).to receive(:collection_members).with(rows: 3).and_return(collection_members)
    expect(document).to receive(:collection_members).at_least(1).times.and_return(collection_members)
    render
  end
  it "should have an icon" do
    expect(rendered).to have_css('.file-icon')
  end
  it "should link the title" do
    expect(rendered).to have_css(".file-title a", text: "File Item")
  end
  it "should include the pub date" do
    expect(rendered).to have_css(".file-title .main-title-date", text: "[2010]")
    expect(rendered).to have_css(".file-title .main-title-date", text: "[2011]")
  end
  it "should display the author" do
    expect(rendered).to have_css(".file-author", text: "Mr. Bean")
  end
end
