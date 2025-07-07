# frozen_string_literal: true

require "rails_helper"

RSpec.describe Feedback::FeedbackFormFieldsComponent, type: :component do
  let(:form) { instance_double(ActionView::Helpers::FormBuilder) }

  before do
    allow(vc_test_controller).to receive_messages(on_campus_or_su_affiliated_user?: false, current_user: User.new)
    allow(form).to receive_messages(text_field: '<input type="text" name="name">'.html_safe,
                                    email_field: '<input type="email" name="to" required="required">'.html_safe,
                                    text_area: '<textarea name="message" required="required"></textarea>'.html_safe,
                                    hidden_field: '<input type="hidden" name="url" value="http://localhost:3000" class="reporting-from-field">'.html_safe)
    render_inline(described_class.new(form: form, request_referer: 'http://localhost:3000'))
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
