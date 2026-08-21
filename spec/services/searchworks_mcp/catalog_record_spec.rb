# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchworksMcp::CatalogRecord do
  describe '.fetch' do
    it 'formats detailed bibliographic metadata with a canonical record URL' do
      document = SolrDocument.new(
        id: '123',
        title_display: 'A catalog record',
        author_person_full_display: ['An Author'],
        format_hsim: ['Book'],
        language: ['English'],
        topic_facet: ['Libraries'],
        imprint_display: 'Stanford University Press, 2026'
      )
      search_service = instance_double(Blacklight::SearchService, fetch: document)
      allow(described_class).to receive(:search_service).and_return(search_service)

      result = described_class.fetch(id: '123')

      expect(result[:structured_content]).to include(
        id: '123',
        title: 'A catalog record',
        url: 'https://searchworks.stanford.edu/view/123'
      )
      expect(result.dig(:structured_content, :metadata)).to include(
        authors: ['An Author'], formats: ['Book'], languages: ['English'], subjects: ['Libraries']
      )
      expect(result[:text]).to include('URL: https://searchworks.stanford.edu/view/123')
    end
  end
end
