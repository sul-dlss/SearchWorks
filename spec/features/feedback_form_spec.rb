# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Feedback form modal", :js do
  before do
    visit root_path
  end

  scenario "feedback form modal should be hidden on page load" do
    expect(page).to have_no_css("#feedback-form", visible: true)
  end

  scenario "feedback form modal should be shown filled out and submitted" do
    skip("Passes locally, not on Travis.") if ENV['CI']
    click_link "Feedback"
    expect(page).to have_css("#feedback-form", visible: true)
    expect(page).to have_css("#feedback_message", count: 1)
    expect(page).to have_text("Open in new tab")
    expect(page).to have_css("button", text: "Close")
    within "form.feedback-form" do
      fill_in("message", with: "This is only a test")
      fill_in("name", with: "Ronald McDonald")
      fill_in("to", with: "test@kittenz.eu")
      click_button "Send"
    end
    expect(page).to have_css("div.toast-body", text: "Thank you!\nYour feedback has been sent.")
  end
end
