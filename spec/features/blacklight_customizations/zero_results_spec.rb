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

  describe 'sidebar' do
    context 'when a user can access the chat widget' do
      let(:user) { User.new(email: 'example@stanford.edu') }

      scenario 'the widget is rendered' do
        within '#sidebar' do
          expect(page).to have_css('h3', text: 'Want help?')
          expect(page).to have_css('h3', text: 'On the library website')
          expect(page).to have_css('a', count: 4)
        end
      end
    end

    context 'when a user cannot access the chat widget' do
      scenario 'the widget is not rendered' do
        within '#sidebar' do
          expect(page).not_to have_css('h3', text: 'Want help?')
        end
      end
    end
  end
end
