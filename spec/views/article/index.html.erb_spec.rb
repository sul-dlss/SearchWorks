require 'spec_helper'

RSpec.describe 'article/index.html.erb' do
  before { render }

  it 'home page' do
    expect(rendered).to have_css('h1', text: 'Find journal articles and other e-resources')
  end

  it '3 column layout' do
    expect(rendered).to have_css('.home-page-column', count: 3)
  end

  it 'first column is a facet column' do
    expect(rendered).to have_css('.home-page-facets h2', text: 'Find materials')
    expect(rendered).to have_css('.home-facet', count: 1)
  end

  it 'second column is a features column' do
    expect(rendered).to have_css('.features h2', text: 'What\'s here?')
    expect(rendered).to have_css('.features h2', text: 'What\'s not?')
  end

  it 'third column is a links column' do
    expect(rendered).to have_css('.articles-help h2', text: 'Related')
    expect(rendered).to have_css('.articles-help ul li', count: 2) # links
  end
end
