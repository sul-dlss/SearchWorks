# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Feedback form modal", :js do
  before do
    visit root_path
  end

  scenario "feedback form modal is be hidden on page load" do
    expect(page).to have_no_css("#feedback-form", visible: true)
  end

  scenario "feedback form modal is shown filled out and submitted" do
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

  scenario "feedback form in a new browser tab" do
    click_link "Feedback"
    expect(page).to have_css("#feedback-form", visible: true)
    click_link 'Open in new tab'

    expect(page).to have_css("#feedback-form", visible: false), 'hides the modal'

    aggregate_failures('shows the feedback form in a new tab') do
      switch_to_window(windows.last)
      expect(page).to have_css(".feedback-form", visible: true)
      within "form.feedback-form" do
        fill_in("message", with: "This is only a test")
        fill_in("name", with: "Ronald McDonald")
        fill_in("to", with: "test@kittenz.eu")
        click_button "Send"
      end
    end

    aggregate_failures('shows the feedback toast in the original tab and closes the new tab') do
      switch_to_window(windows.first)
      expect(page).to have_css("div.toast-body", text: "Thank you!\nYour feedback has been sent.")
      expect(windows.length).to eq(1)
    end
  end

  scenario 'feedback form in a browser tab renders an alert instead of a toast' do
    visit '/feedback'

    within "form.feedback-form" do
      fill_in("message", with: "This is only a test")
      fill_in("name", with: "Ronald McDonald")
      fill_in("to", with: "test@kittenz.eu")
      click_button "Send"
    end

    expect(page).to have_css('.alert', text: "Thank you!\nYour feedback has been sent.")
    expect(page).to have_no_css("div.toast-body", text: "Thank you!\nYour feedback has been sent.")
  end

  scenario 'opening the feedback form from a catalog#show page includes the document summary' do
    visit solr_document_path('1')
    click_link "Feedback"

    expect(page).to have_css("#feedback-form", visible: true)
    within ".record-summary" do
      expect(page).to have_text('An object')
      expect(page).to have_text('Book')
    end
  end
end
