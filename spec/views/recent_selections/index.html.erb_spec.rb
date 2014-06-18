require "spec_helper"

describe "recent_selections/index.html.erb" do
  before do
    document = SolrDocument.new(title_display: "Testing 123")
    assign(:recent_selections, [document])
    render
  end
  it "should have the title" do
    expect(rendered).to have_css("li", text: "Testing 123")
  end
end
