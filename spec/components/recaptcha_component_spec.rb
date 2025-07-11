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
  end
end
