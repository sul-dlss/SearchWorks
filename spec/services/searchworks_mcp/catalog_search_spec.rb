# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchworksMcp::CatalogSearch do
  let(:config) { CatalogController.blacklight_config }

  describe '.filter_facets' do
    it 'includes only facets clients can filter on' do
      facets = described_class.filter_facets(config)

      expect(facets).to include('format', 'library', 'genre')
      expect(facets).not_to include('date', 'course', 'collection', 'acquired_with_support_from', 'iiif_resources')
    end

    it 'distinguishes the Blacklight config key from the Solr field' do
      expect(described_class.filter_facets(config)['library']).to have_attributes(
        label: 'Library', config_key: 'library', solr_field: 'library_code_facet_ssim'
      )
    end
  end

  describe '.facet_params' do
    let(:params) { described_class.send(:facet_params, config) }

    it 'requests only filterable facets' do
      expect(params[:'facet.field']).to include('format_hsim', 'library_code_facet_ssim')
      expect(params[:'facet.field']).not_to include('courses_folio_id_ssim', 'fund_facet', 'pub_year_tisim')
    end

    it 'asks Solr for the most common values of each facet, overriding alphabetical display sorts' do
      expect(params).to include(
        'f.format_hsim.facet.sort': 'count',
        'f.format_hsim.facet.limit': SearchworksMcp::CatalogResults::FACET_VALUE_LIMIT,
        'f.library_code_facet_ssim.facet.sort': 'count'
      )
    end
  end

  describe '.mapped_filters' do
    it 'maps filter names to Blacklight facet config keys and ignores unknown filters' do
      mapped = described_class.send(:mapped_filters, { 'library' => 'ART', 'format' => 'Object', 'bogus' => 'x' }, config)

      expect(mapped).to eq('library' => ['ART'], 'format_hsim' => ['Object'])
    end
  end
end
