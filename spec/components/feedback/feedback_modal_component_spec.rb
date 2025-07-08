# frozen_string_literal: true

require "rails_helper"

RSpec.describe Feedback::FeedbackModalComponent, type: :component do
  before do
    allow(vc_test_controller).to receive_messages(on_campus_or_su_affiliated_user?: false, current_user: User.new)
    render_inline(described_class.new)
  end

  it 'has a link for opening a new tab' do
    expect(page).to have_link("Open in new tab", href: "/feedback")
  end
end
