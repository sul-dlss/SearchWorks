require "spec_helper"

feature "Merged File Collections" do
  scenario "in search results" do
    visit root_path
    fill_in 'q', with: '38'
    click_button 'search'

    expect(page).to have_css('dt', text: "Digital content")
    expect(page).to have_css('dd', text: /\d+ items?/)

    within('.file-collection-members') do
      expect(page).to have_css("a", text: /File Item/, count: 3)
    end
  end
  scenario "record view should display metadata and file list" do
    visit solr_document_path('38')

    expect(page).to have_css('h1', text: 'Merged File Collection1')

    within('.file-collection-members') do
      expect(page).to have_css("a", text: /File Item/, count: 3)
    end

    expect(page).to have_css('h2', text: 'Contents/Summary')
    expect(page).to have_css('h2', text: 'Subjects')
    expect(page).to have_css('h2', text: 'Bibliographic information')
  end
end
