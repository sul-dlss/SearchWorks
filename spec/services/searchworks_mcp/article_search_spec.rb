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
  end
end
