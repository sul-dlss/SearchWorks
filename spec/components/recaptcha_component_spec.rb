# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecaptchaComponent, type: :component do
  before do
    render_inline(described_class.new(action: 'feedback', site_key: 'abc123'))
  end

  it 'renders the component' do
    expect(page).to have_css '[data-recaptcha-target="tags"]'
    expect(page).to have_css '[data-recaptcha-action-value="feedback"]'
    expect(page).to have_css '[data-recaptcha-site-key-value="abc123"]'
    expect(page).to have_css 'input[type="hidden"]#g-recaptcha-response-data-feedback', visible: :hidden
    expect(page).to have_text 'This site is protected by reCAPTCHA and the Google Privacy Policy and Terms of Service apply'
    expect(page).to have_link href: 'https://policies.google.com/privacy'
    expect(page).to have_link href: 'https://policies.google.com/terms'
  end

  it 'does not load the reCAPTCHA script when the page renders' do
    expect(page).to have_no_css 'script', visible: :all
  end

  context 'when reCAPTCHA is not skipped for the environment' do
    before do
      allow(Recaptcha).to receive(:skip_env?).and_return(false)
      render_inline(described_class.new(action: 'feedback', site_key: 'abc123'))
    end

    it 'provides the script url for the controller to load on demand' do
      expect(page).to have_css '[data-recaptcha-script-url-value="https://www.recaptcha.net/recaptcha/api.js?render=abc123"]'
      expect(page).to have_no_css 'script', visible: :all
    end
  end
end
