require 'spec_helper'

feature "Zero results" do
  let(:user) { nil }
  before do
    stub_current_user(user: user, affiliation: 'test-stanford:test')
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)

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
      expect(page).to have_css("h3", text: "Modify your catalog search")
    end
  end
end
