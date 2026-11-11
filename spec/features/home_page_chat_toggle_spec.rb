# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Home page chat toggle', :js do
  it 'slides between the search form and the chat assistant, carrying typed text' do
    login_as(User.create!(email: 'user@stanford.edu', password: 'totallysecurepassword'))
    visit root_path
    fill_in 'q', with: 'beloved toni morrison'

    click_on 'Ask the assistant'

    expect(page).to have_css('#home-mode-chat-tab[aria-selected="true"]')
    expect(page).to have_field('Ask the assistant a question', with: 'beloved toni morrison')
    expect(page).to have_no_css('#q')
    expect(page).to have_current_path('/?mode=chat')

    click_on 'Search'

    expect(page).to have_css('#q')
    expect(page).to have_no_css('.chat-assistant')
    expect(page).to have_current_path('/')
  end

  it 'offers anonymous users a login that returns to the chat' do
    visit '/?mode=chat'

    expect(page).to have_css('#home-mode-chat-tab[aria-selected="true"]')
    expect(page).to have_link('Log in to chat', href: '/sso/login?referrer=%2F%3Fmode%3Dchat')
  end
end
