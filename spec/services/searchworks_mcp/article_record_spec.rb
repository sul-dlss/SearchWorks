# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchworksMcp::ArticleRecord do
  let(:document) do
    instance_double(
      EdsDocument,
      id: 'abc123', eds_title: 'An article', eds_authors: ['An Author'], eds_source_title: 'A Journal',
      eds_publication_date: '2026-08-20', eds_publication_type: 'Academic Journal', eds_document_type: nil,
      eds_abstract: 'An abstract.', eds_subjects: [], eds_languages: ['English'], eds_publisher: 'A Publisher',
      eds_document_doi: '10.1234/example', eds_volume: '1', eds_issue: '2', eds_page_start: '3'
    )
  end

  describe '.fetch' do
    it 'formats detailed article metadata without returning licensed full text' do
      search_service = instance_double(Eds::SearchService, fetch: document)
      allow(described_class).to receive(:search_service).and_return(search_service)
      allow(Settings).to receive(:EDS_ENABLED).and_return(true)

      result = described_class.fetch(id: 'abc123')

      expect(result[:structured_content]).to include(
        id: 'abc123',
        title: 'An article',
        url: 'https://searchworks.stanford.edu/articles/abc123'
      )
      expect(result.dig(:structured_content, :metadata)).to include(
        authors: ['An Author'], source: 'A Journal', abstract: 'An abstract.'
      )
      expect(result.dig(:structured_content, :metadata)).not_to have_key(:full_text)
    end
  end
end
