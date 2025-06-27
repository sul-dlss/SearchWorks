# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Article Home Page' do
  it 'draws the page' do
    visit articles_path

    expect(page).to have_title('SearchWorks articles+ : Stanford Libraries')
    expect(page).to have_css('a', text: /Help/)
  end
end
