# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/searchworks4/_top_navbar' do
  let(:user) { double('user', bookmarks: []) }

  before do
    allow(view).to receive_messages(current_user: user, current_or_guest_user: user)
  end

  describe 'when there is a current user' do
    before do
      allow(user).to receive(:sunet).and_return('jstanford')
      render
    end

    it 'has a logout link' do
      expect(rendered).to have_link('jstanford: Logout')
    end
  end

  describe 'when there is no current user' do
    let(:user) { nil }

    it 'has a login link' do
      render
      expect(rendered).to have_link('Login')
    end
  end
end
