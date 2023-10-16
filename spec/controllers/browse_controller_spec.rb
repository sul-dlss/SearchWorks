require 'rails_helper'

RSpec.describe BrowseController do
  describe 'GET #index' do
    # rubocop:disable RSpec/IndexedLet
    let(:item1) { Holdings::Item.new({ barcode: '123456' }) }
    let(:item2) { Holdings::Item.new({ barcode: '109876' }) }
    # rubocop:enable RSpec/IndexedLet
    let(:original_doc) { instance_double(SolrDocument, items: [item1, item2], preferred_item: item2) }

    before do
      allow(controller).to receive_messages(search_service: double('search_service', fetch: [response, original_doc]), params: { start: 'xyz' }, fetch_original_document: original_doc)
    end

    context 'when params[:barcode] is present' do
      before do
        allow(controller).to receive(:params).and_return(barcode: '123456', start: 'xyz')
      end

      it 'calls NearbyOnShelf.around_item with the correct item' do
        expect(NearbyOnShelf).to receive(:around_item) do |item, _search_service|
          expect(item).to eq(item1)
        end

        get :index

        expect(response).to have_http_status(:success)
      end
    end

    context 'when params[:barcode] is not present' do
      it 'calls NearbyOnShelf.around_item with the correct item' do
        expect(NearbyOnShelf).to receive(:around_item) do |item, _search_service|
          expect(item).to eq(item2)
        end

        get :index

        expect(response).to have_http_status(:success)
      end
    end
  end
end
