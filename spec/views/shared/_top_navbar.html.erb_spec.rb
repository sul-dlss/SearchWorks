require 'spec_helper'

describe 'shared/_top_navbar.html.erb' do
  let(:user) { double('user') }
  before do
    allow(view).to receive(:current_user).and_return(user)
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
