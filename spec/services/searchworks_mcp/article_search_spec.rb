# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchworksMcp::ArticleSearch do
  describe '.search' do
    let(:response) { instance_double(Eds::Response, documents: [], total: 0) }
    let(:search_service) { instance_double(Eds::SearchService, search_results: response) }
    let(:session) { instance_double(Eds::Session, session_token: 'token') }

    before do
      allow(Settings).to receive(:EDS_ENABLED).and_return(true)
      allow(Eds::Session).to receive(:new).and_return(session)
      allow(Eds::SearchService).to receive(:new).and_return(search_service)
    end

    it 'passes the requested number of rows to EDS as per_page' do
      described_class.search(query: 'climate', rows: 5)

      expect(Eds::SearchService).to have_received(:new)
        .with(anything, hash_including(per_page: 5, q: 'climate', search_field: 'search'), anything)
    end

    it 'caps the page size at 20' do
      described_class.search(query: 'climate', rows: 100)

      expect(Eds::SearchService).to have_received(:new).with(anything, hash_including(per_page: 20), anything)
    end

    it 'does not apply any limiters by default' do
      described_class.search(query: 'climate')

      expect(Eds::SearchService).to have_received(:new).with(anything, hash_excluding(:f), anything)
    end

    it 'applies the full text and peer-reviewed limiters when requested' do
      described_class.search(query: 'climate', full_text_only: true, peer_reviewed_only: true)

      expect(Eds::SearchService).to have_received(:new).with(
        anything,
        hash_including(f: { 'eds_search_limiters_facet' => ['Direct access to full text', 'Scholarly & peer-reviewed only'] }),
        anything
      )
    end

    it 'applies only the requested limiter' do
      described_class.search(query: 'climate', peer_reviewed_only: true)

      expect(Eds::SearchService).to have_received(:new).with(
        anything,
        hash_including(f: { 'eds_search_limiters_facet' => ['Scholarly & peer-reviewed only'] }),
        anything
      )
    end
  end
end
