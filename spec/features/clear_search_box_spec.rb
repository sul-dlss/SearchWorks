require "spec_helper"

feature "Search box", js: true do
  scenario "clear query text" do
    visit root_path

    fill_in 'q', with: 'xyz'
    expect(page).to have_css('.search-form a.clear-input-text', visible: true)

    find('.search-form a.clear-input-text').click
    expect(find_field('q').value).to eq ''
    expect(page).to have_css('.search-form a.clear-input-text', visible: false)
  end
end
