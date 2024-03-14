# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BrowseController do
  describe 'GET #index' do
    let(:original_doc) do
      SolrDocument.new(id: 'abc123', preferred_barcode: '109876', item_display_struct: [{ barcode: '109876', id: 'b', lopped_callnumber: 'B' }], browse_nearby_struct:)
    end

    let(:browse_nearby_struct) do
      [
        { item_id: 'a', lopped_callnumber: 'A', shelfkey: 'A', scheme: 'LC' }.with_indifferent_access,
        { item_id: 'b', lopped_callnumber: 'B', shelfkey: 'B', scheme: 'LC' }.with_indifferent_access,
        { item_id: 'c', lopped_callnumber: 'C', shelfkey: 'C', scheme: 'LC' }.with_indifferent_access
      ]
    end

    before do
      allow(controller).to receive_messages(search_service: double('search_service', fetch: [response, original_doc]), params: { start: 'xyz' }, fetch_original_document: original_doc)
    end

    context 'when params[:call_number] is present' do
      before do
        allow(controller).to receive(:params).and_return(call_number: 'C', start: 'xyz')
      end

      it 'calls NearbyOnShelf.around_spine with the correct item' do
        expect(NearbyOnShelf).to receive(:around_spine) do |item, _search_service|
          expect(item).to have_attributes(shelfkey: 'C')
        end

        get :index

        expect(response).to have_http_status(:success)
      end
    end

    context 'when params[:barcode] is not present' do
      it 'calls NearbyOnShelf.around_spine with the correct item' do
        expect(NearbyOnShelf).to receive(:around_spine) do |spine, _search_service|
          expect(spine).to have_attributes(shelfkey: 'B')
        end

        get :index

        expect(response).to have_http_status(:success)
      end
    end
  end
end
