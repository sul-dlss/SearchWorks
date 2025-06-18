# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'search/_module_heading' do
  let(:result) do
    instance_double(CatalogSearchService::Response, total: total)
  end
  let(:service) { Service.new('catalog') }
  let(:presenter) do
    SearchPresenter.new(service, result, 'climate change')
  end

  before do
    allow(presenter).to receive(:see_all_link).and_return('https://searchworks.stanford.edu/articles?q=climate%20change')
    render 'search/module_heading', presenter:
  end

  context 'with no results' do
    let(:total) { 0 }

    it 'renders' do
      expect(rendered).to have_css('.result-set-heading', text: 'Catalog')
      expect(rendered).to have_css('.result-set-subheading', text: /Physical and digital collections/)
      expect(rendered).to have_no_link
    end
  end

  context 'with 1 result' do
    let(:total) { 1 }

    it 'renders' do
      expect(rendered).to have_css('.result-set-heading', text: 'Catalog')
      expect(rendered).to have_css('.result-set-subheading', text: /Physical and digital collections/)
      expect(rendered).to have_link 'See 1 catalog result'
    end
  end

  context 'with 2 result' do
    let(:total) { 2 }

    it 'renders' do
      expect(rendered).to have_css('.result-set-heading', text: 'Catalog')
      expect(rendered).to have_css('.result-set-subheading', text: /Physical and digital collections/)
      expect(rendered).to have_link 'See 2 catalog results'
    end
  end

  context 'with 3 results' do
    let(:total) { 3 }

    it 'renders' do
      expect(rendered).to have_css('.result-set-heading', text: 'Catalog')
      expect(rendered).to have_css('.result-set-subheading', text: /Physical and digital collections/)
      expect(rendered).to have_link 'See 3 catalog results'
    end
  end

  context 'with 4 results' do
    let(:total) { 4 }

    it 'renders' do
      expect(rendered).to have_css('.result-set-heading', text: 'Catalog')
      expect(rendered).to have_css('.result-set-subheading', text: /Physical and digital collections/)
      expect(rendered).to have_link 'See all 4 catalog results'
    end
  end

  context 'with 100 results for lib_guides' do
    let(:total) { 100 }
    let(:service) { Service.new('lib_guides') }

    it 'renders' do
      expect(rendered).to have_css('.result-set-heading', text: 'Guides')
      expect(rendered).to have_css('.result-set-subheading', text: /Course and topic guides/)
      expect(rendered).to have_link 'See all 100+ lib guides results'
    end
  end
end
