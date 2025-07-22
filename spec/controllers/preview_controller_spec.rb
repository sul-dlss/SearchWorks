# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PreviewController do
  describe "#show" do
    document_id = 1
    it "gets the document" do
      get :show, params: { id: document_id }
      expect(assigns[:document]).not_to be_nil
    end
  end
end
