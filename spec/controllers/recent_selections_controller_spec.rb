require "spec_helper"

describe RecentSelectionsController do
  describe "#index" do
    it "should get the document" do
      @controller.stub_chain(:current_or_guest_user, :bookmarks).and_return([OpenStruct.new({document_id: "1"})])
      get :index, xhr: true
      expect(response).to render_template("index")
      expect(assigns[:recent_selections]).to_not be_nil
    end
  end
end
