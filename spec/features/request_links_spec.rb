require "spec_helper"

describe 'Request Links', type: :feature do
  it do
    visit catalog_path(id: 54)
    expect(page).to have_css '.request-button', text: 'Request on-site access'
  end
end
