# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecaptchaWithLoginLinkComponent, type: :component do
  before do
    render_inline(described_class.new(recaptcha_id: 'my-recaptcha-id'))
  end

  it 'renders the component' do
    expect(page).to have_link 'Log in'
    expect(page).to have_css '#my-recaptcha-id'
  end
end
