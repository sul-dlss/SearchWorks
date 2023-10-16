require 'rails_helper'

RSpec.describe 'shared/_top_navbar' do
  let(:user) { double('user') }

  before do
    expect(view).to receive(:current_user).at_least(:once).and_return(user)
    expect(view).to receive(:on_campus_or_su_affiliated_user?).and_return(true)
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
