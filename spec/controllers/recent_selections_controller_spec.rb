require "spec_helper"

describe RecentSelectionsController do
  let(:bookmarks) { Array.wrap(instance_double(Bookmark, document_id: '1')) }
  let(:guest_user) { instance_double(User) }

  before do
    expect(controller).to receive(:current_or_guest_user).and_return(guest_user)
    expect(guest_user).to receive(:bookmarks).and_return(bookmarks)
  end

  describe "#index" do
    it "should get the document" do
      xhr :get, :index
      expect(response).to render_template("index")
      expect(assigns[:recent_selections]).to_not be_nil
    end
  end
end
