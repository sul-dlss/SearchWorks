require 'spec_helper'

RSpec.describe BookmarksController do
  let(:user) { User.create!(email: 'example@stanford.edu', password: 'totallysecurepassword') }

  before { stub_current_user(user: user) }

  describe '#create' do
    it 'creates bookmarks for catalog entries' do
      expect do
        put :create, xhr: true, params: {
          bookmarks: [
            { document_id: '2007020969', document_type: 'SolrDocument', record_type: 'catalog' }
          ],
          format: :js
        }
      end.to change { Bookmark.where(record_type: 'catalog').count }.by(1)
    end

    it 'creates bookmarks for articles' do
      expect do
        put :create, xhr: true, params: {
          bookmarks: [
            { document_id: '2007020969', document_type: 'SolrDocument', record_type: 'article' }
          ],
          format: :js
        }
      end.to change { Bookmark.where(record_type: 'article').count }.by(1)
    end
  end
end
