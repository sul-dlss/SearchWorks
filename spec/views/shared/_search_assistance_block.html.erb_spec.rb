# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/_search_assistance_block' do
  before do
    controller.params[:q] = 'abc123'
    allow(view).to receive(:controller_name).and_return('catalog')
  end

  context 'catalog' do
    it 'displays catalog specific links' do
      render
      expect(rendered).to have_css 'a[href*="abc123"]', text: 'WorldCat'
      expect(rendered).to have_css 'a[href*="abc123"]', text: 'HathiTrust'
    end
  end

  context 'articles' do
    before do
      allow(view).to receive(:controller_name).and_return('articles')
    end

    it 'displays articles specific links' do
      render
      expect(rendered).to have_css 'a', text: 'Databases'
    end
  end

  context 'shared' do
    it 'displays links regardless of search context' do
      render
      expect(rendered).to have_css 'h3', text: 'More options'
      expect(rendered).to have_css 'a', text: 'Interlibrary loan'
      expect(rendered).to have_css 'a', text: 'Search tools'
    end
  end
end
