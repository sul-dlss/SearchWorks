# frozen_string_literal: true

require "rails_helper"

RSpec.describe Feedback::FeedbackModalComponent, type: :component do
  before do
    allow(vc_test_controller).to receive_messages(current_user: User.new)
    allow(vc_test_controller.request).to receive(:referer).and_return('http://localhost:3000')
    render_inline(described_class.new)
  end

  it 'has a link for opening a new tab' do
    expect(page).to have_link("Open in new tab", href: "/feedback")
  end

  it 'displays the reporting alert box with specific information' do
    expect(page).to have_text("Reporting from")
    expect(page).to have_link("Check system status")
  end
end
