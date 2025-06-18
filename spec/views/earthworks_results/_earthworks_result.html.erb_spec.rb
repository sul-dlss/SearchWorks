# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'earthworks_results/_earthworks_result' do
  let(:description) { 'The Description' }
  let(:earthworks_result) do
    EarthworksResult.new(
      title: 'Title',
      link: 'http://example.com',
      description: description,
      author: 'The Author'
    )
  end

  before do
    render 'earthworks_results/earthworks_result', earthworks_result:
  end

  it 'links to the title' do
    within 'h3' do
      expect(rendered).to have_link('Title', href: 'http://example.com')
    end
  end

  it 'renders the author' do
    expect(rendered).to have_content('The Author')
  end

  it 'renders the description' do
    expect(rendered).to have_css('p', text: 'The Description')
  end
end
