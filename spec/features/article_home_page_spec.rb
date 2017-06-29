require 'spec_helper'

feature 'Article Home Page' do
  before { visit article_home_path }

  it 'has fielded search' do
    within '#search_field' do
      %w[search author title subject journal_title abstract issn isbn].each do |search_field|
        expect(page).to have_css("option[value=\"#{search_field}\"]")
      end
      expect(page).not_to have_css("option[selected]") # defaults to top one (i.e., search)
    end
  end
end
