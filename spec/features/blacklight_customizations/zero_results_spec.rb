require 'spec_helper'

feature "Zero results" do
  let(:user) { nil }
  before do
    stub_current_user(user: user)
    visit root_path
    first("#q").set '9999zzzz2222'
    click_button 'search'
  end
  scenario "search widgets and start over should not be present" do
    expect(page).to_not have_css("a.catalog_startOverLink", text: /Catalog start/i)
    expect(page).to_not have_css("div#search-widgets")
  end

  scenario "should have correct headings and elements present" do
    within "#content" do
      expect(page).to have_css("h3", text: "Modify your search")
      expect(page).to have_css("h3", text: "Check other sources")
    end
  end

  describe 'search context sidebar' do
    context 'catalog' do
      scenario 'links to articles+' do
        within '#sidebar' do
          expect(page).to_not have_css('span.h3', text: 'catalog')
          expect(page).to have_css('a', text: 'articles+')
          expect(page).to have_css('a', text: 'library website')
          expect(page).to have_css('a', text: 'all')
          expect(page).to have_css('a', count: 3)
        end
      end
    end

    context 'articles' do
      scenario 'links to catalog' do
        within '#sidebar' do
          expect(page).to have_css('a', text: 'library website')
          expect(page).to have_css('a', text: 'all')
          expect(page).to have_css('a', count: 3)
        end
      end
    end
  end
end
