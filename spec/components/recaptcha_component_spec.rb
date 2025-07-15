# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecaptchaComponent, type: :component do
  before do
    render_inline(described_class.new(action: 'feedback'))
  end

  it 'renders the component' do
    expect(page).to have_css '[data-recaptcha-target="tags"]'
    expect(page).to have_css '[data-recaptcha-action-value="feedback"]'
    expect(page).to have_css '[data-recaptcha-site-key-value]'
    expect(page).to have_text 'This site is protected by reCAPTCHA and the Google Privacy Policy and Terms of Service apply'
    expect(page).to have_link href: 'https://policies.google.com/privacy'
    expect(page).to have_link href: 'https://policies.google.com/terms'
  end
end
