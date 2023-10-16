require 'rails_helper'

RSpec.describe "shared/_zero_results" do
  let(:config) {
    Blacklight::Configuration.new do |config|
      config.add_search_field 'search', label: 'All fields'
      config.add_facet_field 'fieldA', label: "A field"
      config.add_facet_field 'fieldB', label: 'Another field'
    end
  }

  let(:search_state) do
    Blacklight::SearchState.new({
      q: "A query",
      f: { 'fieldA' => ["ValueA"], 'fieldB' => ['ValueB'] },
      search_field: 'search_title'
    }, config)
  end

  before do
    assign(:search_modifier, SearchQueryModifier.new(search_state))
    allow(view).to receive_messages(controller_name: 'catalog', label_for_search_field: 'Title')
  end

  it "displays modify your search" do
    render
    expect(rendered).to have_css("h3", text: "Modify your catalog search")
  end

  it "renders text indicating tips to modify the search along with links to the relevant search" do
    render
    expect(rendered).to have_css("a", text: /Title >/)
    expect(rendered).to have_css("li", text: 'Remove limit(s)')
    expect(rendered).to have_css("li", text: /Search all fields/)
  end

  it 'renders search tools' do
    render
    expect(rendered).to have_css("a", text: /Search tools/)
  end

  it 'renders alternate catalog' do
    allow(view).to receive_messages(show_alternate_catalog?: true, params: { q: 'test123' })
    stub_template '_alternate_catalog.html.erb' => '<div class="alternate-catalog"></div>'
    render
    expect(rendered).to have_css '.alternate-catalog'
  end
end
