require "spec_helper"

describe "shared/_zero_results.html.erb" do
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
      f: {'fieldA' => ["ValueA"], 'fieldB' => ['ValueB']},
      search_field: 'search_title'
    }, config))
    allow(view).to receive(:controller_name).and_return('catalog')
    allow(view).to receive(:label_for_search_field).and_return('Title')
    allow(view).to receive(:on_campus_or_su_affiliated_user?).and_return(true)
  end

  it "displays modify your search" do
    render
    expect(rendered).to have_css("h3", text: "Modify your search")
  end

  it "renders text indicating tips to modify the search along with links to the relevant search" do
    render
    expect(rendered).to have_css("dt", text: /Your current search/)
    expect(rendered).to have_css("a", text: /Title >/)
    expect(rendered).to have_css("dt", text: 'Remove limit(s)')
    expect(rendered).to have_css("dt", text: /Search all fields/)
  end

  it "renders chat and search tools" do
    render
    expect(rendered).to have_css("a", text: /Chat with a librarian/)
    expect(rendered).to have_css("a", text: /Search tools/)
  end
end
