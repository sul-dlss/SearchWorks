# frozen_string_literal: true

require "rails_helper"

RSpec.describe Feedback::FeedbackStandaloneComponent, type: :component do
  before do
    allow(vc_test_controller).to receive_messages(on_campus_or_su_affiliated_user?: false, current_user: User.new)
    render_inline(described_class.new)
  end

  it 'sets up a standalone container' do
    expect(page).to have_css('div.standalone')
  end

  it 'contains the feedback form title' do
    expect(page).to have_css('h2', text: 'Send feedback')
  end
end
