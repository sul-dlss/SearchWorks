require 'rails_helper'

RSpec.describe "recent_selections/index" do
  before do
    assign(:catalog_count, 500)
    assign(:article_count, 45)
    render
  end

  it 'has the counts' do
    expect(rendered).to have_link 'Catalog selections (500)'
    expect(rendered).to have_link 'Articles+ selections (45)'
  end
end
