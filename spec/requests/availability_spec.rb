# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Getting availability information' do
  context 'when successful' do
    before do
      allow(LiveLookup).to receive(:new).with('b0e0445b-dc19-5e05-a85c-5ecbad784255').and_return(live_lookup)
    end

    let(:live_lookup) { instance_double(LiveLookup, records: [{ item_id: '217453b4-0585-517f-859c-bab10d948554' }]) }

    it 'looks up the document and RTAC' do
      get '/availability/1391872'
      expect(response).to be_successful

      body = Capybara::Node::Simple.new(response.body)
      expect(body).to have_css "turbo-frame#availability_solr_document_1391872"
      expect(body).to have_css 'turbo-stream[target="availability_item_217453b4-0585-517f-859c-bab10d948554"]'
      expect(response.body).to include 'Available'
    end
  end

  context 'when FOLIO login fails' do
    before do
      allow(LiveLookup).to receive(:new).with('b0e0445b-dc19-5e05-a85c-5ecbad784255').and_raise(FolioClient::Error)
    end

    it 'sets and error response' do
      get '/availability/1391872'
      expect(response).to be_successful
      body = Capybara::Node::Simple.new(response.body)
      expect(body).to have_css "turbo-frame#availability_solr_document_1391872"
      expect(response.body).to include '<p>Unable to retrieve availability information.</p>'
    end
  end
end
