require 'spec_helper'

feature 'Article Home Page' do
  before do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
    visit article_index_path
  end

  it 'has the correct title' do
    expect(page).to have_title('SearchWorks articles : Stanford Libraries')
  end

  it 'has fielded search' do
    within '#search_field' do
      %w[search author title subject source abstract issn isbn].each do |search_field|
        expect(page).to have_css("option[value=\"#{search_field}\"]")
      end
      expect(page).not_to have_css("option[selected]") # defaults to top one (i.e., search)
    end
  end
end
