# frozen_string_literal: true

require "rails_helper"

RSpec.describe Feedback::FeedbackStandaloneComponent, type: :component do
  before do
    allow(vc_test_controller).to receive_messages(current_user: User.new)
    allow(vc_test_controller.request).to receive(:referer).and_return('http://localhost:3000')
    render_inline(described_class.new)
  end

  it 'sets up a standalone container' do
    expect(page).to have_css('div.standalone')
  end

  it 'contains the feedback form title' do
    expect(page).to have_css('h2', text: 'Send feedback')
  end

  it 'displays the reporting alert box with specific information' do
    expect(page).to have_text("Reporting from")
    expect(page).to have_link("Check system status")
  end
end
