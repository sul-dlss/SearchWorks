require 'spec_helper'

RSpec.describe ArticleSearchBuilder do
  subject(:search_builder) { described_class.new(ArticleController).with(blacklight_params).to_hash }

  context 'basic search' do
    let(:blacklight_params) { { q: 'my search', page: 1, per_page: 10 } }
    it 'maps to EDS API' do
      expect(search_builder[:q]).to eq 'my search'
      expect(search_builder[:page_number]).to eq 1
      expect(search_builder[:results_per_page]).to eq 10
      expect(search_builder[:highlight]).to eq 'y'
    end

    it 'excludes some Solr-like parameters' do
      expect(search_builder['start']).to be_nil
      expect(search_builder['rows']).to be_nil
      expect(search_builder['page']).to be_nil
      expect(search_builder['per_page']).to be_nil
    end

    it 'has a simple processor chain' do
      expect(described_class.default_processor_chain).to eq %i[add_eds_params]
    end
  end

  context 'paged search' do
    let(:blacklight_params) { { q: 'my search', page: 12 } }
    it 'maps to EDS API' do
      expect(search_builder[:page_number]).to eq 12
      expect(search_builder[:results_per_page]).to eq 20
    end
  end

  context 'per page change' do
    let(:blacklight_params) { { q: 'my search', per_page: 100 } }
    it 'maps to EDS API' do
      expect(search_builder[:page_number]).to eq 1
      expect(search_builder[:results_per_page]).to eq 100
    end
  end

  context 'faceted search' do
    let(:blacklight_params) { { f: { facet_name: 'facet value' } } }
    it 'maps to EDS API' do
      expect(search_builder[:f][:facet_name]).to eq 'facet value'
    end
  end
end
