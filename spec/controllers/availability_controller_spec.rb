# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AvailabilityController do
  describe "bot traffic" do
    it "returns a forbidden status" do
      request.env['HTTP_USER_AGENT'] = 'robot'
      get :show, params: { id: ['123'] }
      expect(response).to be_forbidden
    end
  end
end
