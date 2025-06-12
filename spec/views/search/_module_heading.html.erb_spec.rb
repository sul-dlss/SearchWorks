# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'search/_module_heading' do
  let(:catalog) do
    instance_double(QuickSearch::CatalogSearcher, total: total, see_all_link: 'https://searchworks.stanford.edu/articles?q=climate%20change')
  end

  before do
    render 'search/module_heading', service_name: 'catalog', searcher: catalog
  end

  context 'with no results' do
    let(:total) { 0 }

    it 'renders' do
      expect(rendered).to have_css('.result-set-heading', text: 'Catalog')
      expect(rendered).to have_css('.result-set-subheading', text: /Books, journals, media, and more/)
      expect(rendered).to have_no_link
    end
  end

  context 'with 1 result' do
    let(:total) { 1 }

    it 'renders' do
      expect(rendered).to have_css('.result-set-heading', text: 'Catalog')
      expect(rendered).to have_css('.result-set-subheading', text: /Books, journals, media, and more/)
      expect(rendered).to have_link 'See 1 catalog result'
    end
  end

  context 'with 2 result' do
    let(:total) { 2 }

    it 'renders' do
      expect(rendered).to have_css('.result-set-heading', text: 'Catalog')
      expect(rendered).to have_css('.result-set-subheading', text: /Books, journals, media, and more/)
      expect(rendered).to have_link 'See 2 catalog results'
    end
  end

  context 'with 3 results' do
    let(:total) { 3 }

    it 'renders' do
      expect(rendered).to have_css('.result-set-heading', text: 'Catalog')
      expect(rendered).to have_css('.result-set-subheading', text: /Books, journals, media, and more/)
      expect(rendered).to have_link 'See 3 catalog results'
    end
  end

  context 'with 4 results' do
    let(:total) { 4 }

    it 'renders' do
      expect(rendered).to have_css('.result-set-heading', text: 'Catalog')
      expect(rendered).to have_css('.result-set-subheading', text: /Books, journals, media, and more/)
      expect(rendered).to have_link 'See all 4 catalog results'
    end
  end
end
