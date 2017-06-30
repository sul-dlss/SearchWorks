require 'spec_helper'

feature 'Article Home Page' do
  skip('need to stub out Eds::SearchService') if ENV['CI']
  before { visit article_index_path }

  xit 'has fielded search' do
    skip('need to stub out Eds::SearchService') if ENV['CI']
    within '#search_field' do
      %w[search author title subject source abstract issn isbn].each do |search_field|
        expect(page).to have_css("option[value=\"#{search_field}\"]")
      end
      expect(page).not_to have_css("option[selected]") # defaults to top one (i.e., search)
    end
  end
end
