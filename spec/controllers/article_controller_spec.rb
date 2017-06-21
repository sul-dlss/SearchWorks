require 'spec_helper'

RSpec.describe ArticleController do
  context '#new' do
    it 'shows a home page' do
      get :new
      expect(response).to render_template('new')
    end
  end

  it 'handles authentication'
  it 'handles configuration'

  context 'Article Search API (via EDS)' do
    before do
      expect(controller).to receive(:eds_init).and_return(nil)
      @search_service = instance_double(Eds::SearchService)
      expect(Eds::SearchService).to receive(:new).and_return(@search_service)
    end

    it '#index' do
      expect(@search_service).to receive(:search_results)
      get :index
    end

    it '#show' do
      expect(@search_service).to receive(:fetch).with('123')
      get :show, params: { id: 123 }
    end
  end
end
