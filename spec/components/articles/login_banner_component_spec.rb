# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Articles::LoginBannerComponent, type: :component do
  subject(:component) { described_class.new }

  let(:current_user) { nil }

  before do
    allow(vc_test_controller).to receive_messages(current_user:)
  end

  context 'when the user is logged in' do
    let(:current_user) { User.new }

    it 'is empty' do
      render_inline(component)

      expect(page.native.inner_html).to be_blank
    end
  end

  context 'when there is no user' do
    it 'renders' do
      render_inline(component)

      expect(page).to have_css '.alert'
      expect(page).to have_content 'Stanford affiliates: Log in to view all results and benefit from streamlined access to articles and more.'
    end
  end
end
