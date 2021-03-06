require "spec_helper"

describe "recent_selections/index.html.erb" do
  before do
    assign(:catalog_count, 500)
    assign(:article_count, 45)
    render
  end

  it 'has the counts' do
    expect(rendered).to have_css('li a', text: 'Catalog selections (500)')
    expect(rendered).to have_css('li a', text: 'Articles+ selections (45)')
  end
end
