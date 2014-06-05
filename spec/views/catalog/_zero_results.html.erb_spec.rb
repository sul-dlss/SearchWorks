require "spec_helper"

describe "catalog/_zero_results.html.erb" do
  let(:config) {
    Blacklight::Configuration.new do |config|
      config.add_search_field 'search', label: 'All fields'
      config.add_facet_field 'fieldA', label: "A field"
      config.add_facet_field 'fieldB', label: 'Another field'
    end
  }
  before do
    assign(:search_modifier, SearchQueryModifier.new({
      q: "A query",
      f: {'fieldA' => "ValueA", 'fieldB' => 'ValueB'},
      search_field: 'search_title'
    }, config))
    view.stub(:label_for_search_field).and_return('Title')
  end

  it "should display modify your search" do
    render
    expect(rendered).to have_css("h3", text: "Modify your search")
  end

  it "should render text indicating tips to modify the search along with links to the relevant search" do
    render
    expect(rendered).to have_css("li", text: /you searched by Title/)
    expect(rendered).to have_css("a", text: 'try searching everything')
    expect(rendered).to have_css("li", text: /you limited your search by A field, Another field/)
    expect(rendered).to have_css("a", text: 'try removing limits')
  end

  it "should display check other sources" do
    render
    expect(rendered).to have_css("h3", text: "Check other sources")
    expect(rendered).to have_css("a", text: "Check WorldCat")
    expect(rendered).to have_css("a", text: "Check articles")
    expect(rendered).to have_css("a", text: "Check library website")
  end

end
