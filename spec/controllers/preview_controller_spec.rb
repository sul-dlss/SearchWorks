# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PreviewController do
  describe "#show" do
    doc_id = 1
    it "should get the document" do
      get :show, params: { id: doc_id }
      expect(assigns[:document]).not_to be_nil
    end
  end
end
