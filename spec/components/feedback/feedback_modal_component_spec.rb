# frozen_string_literal: true

require "rails_helper"

RSpec.describe Feedback::FeedbackModalComponent, type: :component do
  before do
    allow(vc_test_controller).to receive_messages(on_campus_or_su_affiliated_user?: false, current_user: User.new)
    render_inline(described_class.new)
  end

  it 'contains flash messages section for standalone alerts' do
    expect(page).to have_css('.feedback-alert #main-flashes')
  end

  it 'sets up a modal container' do
    expect(page).to have_css('div[data-blacklight-modal]')
  end

  it 'displays the alert box with specific information' do
    expect(page).to have_css("div.alert div.text-body div.col-8", text: "Reporting from")
    expect(page).to have_css("div.alert div.text-body div.col-4 a", text: "Check system status")
  end

  it 'contains specific form fields' do
    expect(page).to have_css("textarea[name='message'][required='required']")
    expect(page).to have_css("input[name='to'][required='required']")
    expect(page).to have_field(name: "name")
  end

  it 'contains a chat with librarian section' do
    expect(page).to have_content("Chat with a librarian")
  end

  it 'has link for opening a new tab' do
    expect(page).to have_link("Open in new tab", href:"/feedback")
  end
end
