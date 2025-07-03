# frozen_string_literal: true

require "rails_helper"

RSpec.describe Feedback::FeedbackFormComponent, type: :component do
  before do
    allow(vc_test_controller).to receive_messages(on_campus_or_su_affiliated_user?: false, current_user: User.new)
    render_inline(described_class.new)
  end

  it 'displays the reporting alert box with specific information' do
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
end
