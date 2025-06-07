# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Top Navigation" do
  it "has navigational links and top menu" do
    visit root_path
    within "header > nav" do
      expect(page).to have_link "Login"
      expect(page).to have_link "Feedback"
    end
  end
end
