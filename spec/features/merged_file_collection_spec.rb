require 'rails_helper'

RSpec.feature "Merged File Collections", :js do
  before do
    stub_article_service(docs: [])
  end

  scenario "in search results" do
    visit root_path
    fill_in 'q', with: '38'
    find('button#search').click

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

    expect(page).to have_css('h3', text: 'Contents/Summary')
    expect(page).to have_css('h3', text: 'Subjects')
    expect(page).to have_css('h3', text: 'Bibliographic information')
  end
end
