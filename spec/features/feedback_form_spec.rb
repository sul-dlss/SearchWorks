# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Feedback form (js)", :js do
  before do
    visit root_path
  end

  scenario "feedback form should be hidden" do
    expect(page).to have_no_css("#feedback-form", visible: true)
  end
  scenario "feedback form should be shown filled out and submitted" do
    skip("Passes locally, not on Travis.") if ENV['CI']
    click_link "Feedback"
    expect(page).to have_css("#feedback-form", visible: true)
    expect(page).to have_css("#feedback_message", count: 1)
    expect(page).to have_css("button", text: "Cancel")
    within "form.feedback-form" do
      fill_in("message", with: "This is only a test")
      fill_in("name", with: "Ronald McDonald")
      fill_in("to", with: "test@kittenz.eu")
      click_button "Send"
    end
    expect(page).to have_css("div.alert-success", text: "Thank you! Your feedback has been sent.")
  end
end

RSpec.feature "Feedback form (no js)" do
  before do
    visit root_path
  end

  scenario "feedback form should be shown filled out and submitted" do
    click_link "Feedback"
    expect(page).to have_css("#feedback-form", visible: true)
    expect(page).to have_css("#feedback_message", count: 1)
    expect(page).to have_css("a", text: "Cancel")
    within "form.feedback-form" do
      fill_in("message", with: "This is only a test")
      fill_in("name", with: "Ronald McDonald")
      fill_in("to", with: "test@kittenz.eu")
      click_button "Send"
    end
    expect(page).to have_css("div.alert-success", text: "Thank you! Your feedback has been sent.")
  end
end
