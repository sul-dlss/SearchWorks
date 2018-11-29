require "spec_helper"

describe BrowseController, :"data-integration" => true do
  describe "routes" do
    it "should be accessible via /browse" do
      expect({get: "/browse"}).to route_to(controller: 'browse', action: 'index')
      expect({get: "/browse/nearby"}).to route_to(controller: 'browse', action: 'nearby')
    end
  end
  describe "#index" do
    before do
      get :index, params: { start: '9696118' }
    end
    it "should set the @document_list instance variable" do
      expect(assigns(:document_list)).to be_present
    end
    it "should include the originating document" do
      expect(assigns(:document_list).any? do |doc|
        doc[:id] == assigns(:original_doc)[:id]
      end).to be_truthy
    end
    it "should return a SolrDocuments object" do
      assigns(:document_list).each do |doc|
        expect(doc).to be_a(SolrDocument)
      end
    end
    it "should set the @original_doc instance variable" do
      expect(assigns(:original_doc)).to be_present
    end
  end
  describe "w/o start param" do
    it "should not throw an error" do
      get :index
      expect(response).to be_success
      expect(assigns(:original_doc)).not_to be_present
    end
  end
  describe "pagination" do
    describe "forward" do
      it "should not include the original doc" do
        get :index, params: { start: '9696118', page: '1' }
        expect(assigns(:document_list).any? do |doc|
          doc[:id] == assigns(:original_doc)[:id]
        end).to be_falsey
      end
    end
    describe "backward" do
      it "should not include the original doc" do
        get :index, params: { start: '9696118', page: '-1' }
        expect(assigns(:document_list).any? do |doc|
          doc[:id] == assigns(:original_doc)[:id]
        end).to be_falsey
      end
    end
  end
  describe "nearby" do
    before do
      get :nearby, params: { start: '9696118' }
    end
    it "should set the @document_list instance variable" do
      expect(assigns(:document_list)).to be_present
    end
    it "should include the originating document" do
      expect(assigns(:document_list).any? do |doc|
        doc[:id] == assigns(:original_doc)[:id]
      end).to be_truthy
    end
    it "should return a SolrDocuments object" do
      assigns(:document_list).each do |doc|
        expect(doc).to be_a(SolrDocument)
      end
    end
  end
end
