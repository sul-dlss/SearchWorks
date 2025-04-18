# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Search parameters in all caps" do
  it "is downcased" do
    visit root_path
    fill_in 'q', with: "HELLO WORLD"
    click_button 'search'

    within('.breadcrumb') do
      expect(page).to have_no_content("HELLO WORLD")
      expect(page).to have_content("hello world")
    end

    text_field = find_by_id('q')
    expect(text_field.value).not_to eq 'HELLO WORLD'
    expect(text_field.value).to eq 'hello world'
  end

  it 'handles a nil query' do
    expect do
      visit '/catalog?q'
    end.not_to raise_error
  end
end
