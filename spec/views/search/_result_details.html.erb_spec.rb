# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'search/_result_details' do
  let(:description) { 'The Description' }
  let(:result) do
    SearchResult.new(
      title: 'Title',
      link: 'http://example.com',
      description: description,
      author: 'The Author',
      imprint: 'Oxford : Oxford University Press, 2013.',
      fulltext_link_html: '<a href="#">Link</a>'
    )
  end

  before do
    without_partial_double_verification do
      allow(view).to receive(:result).and_return(result)
    end

    render
  end

  it 'links to the title' do
    within 'h3' do
      expect(rendered).to have_link('Title', href: 'http://example.com')
    end
  end

  it 'renders the author' do
    expect(rendered).to have_content('The Author')
  end

  it 'renders the imprint' do
    expect(rendered).to have_content 'Oxford : Oxford University Press, 2013.'
  end

  it 'renders the description' do
    expect(rendered).to have_css('p', text: 'The Description')
  end

  it 'renders the fulltext link html' do
    within 'p' do
      expect(rendered).to have_link('Link', href: '#')
    end
  end
end
