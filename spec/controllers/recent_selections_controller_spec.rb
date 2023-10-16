require 'rails_helper'

RSpec.describe RecentSelectionsController do
  describe "#index" do
    let(:user) { User.create!(email: 'example@stanford.edu', password: 'totallysecurepassword') }
    let!(:cat_bookmark1) { Bookmark.create!(document_id: '1', user:) }
    let!(:cat_bookmark2) { Bookmark.create!(document_id: '2', user:) }
    let!(:article_bookmark) { Bookmark.create!(document_id: 'abc__1', user:, record_type: 'article') }

    it 'returns the counts of article and catalog bookmarks' do
      allow(controller).to receive(:current_or_guest_user).and_return(user)
      get :index, xhr: true
      expect(response).to render_template('index')
      expect(assigns(:catalog_count)).to eq 2
      expect(assigns(:article_count)).to eq 1
    end
  end
end
