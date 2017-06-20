require 'spec_helper'

describe PreviewController do
  describe "#show" do
    doc_id = 1
    it "should get the document" do
      get :show, params: { id: doc_id }
      expect(assigns[:document]).to_not be_nil
    end
  end
end
