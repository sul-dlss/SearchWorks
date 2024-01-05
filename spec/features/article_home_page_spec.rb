require 'rails_helper'

RSpec.feature 'Article Home Page' do
  before { stub_article_service(docs: StubArticleService::SAMPLE_RESULTS) }

  it 'has the correct title' do
    visit articles_path

    expect(page).to have_title('SearchWorks articles+ : Stanford Libraries')
  end

  it 'has fielded search' do
    visit articles_path

    within '#search_field' do
      %w[search author title subject source].each do |search_field|
        expect(page).to have_css("option[value=\"#{search_field}\"]")
      end
      expect(page).to have_no_css("option[selected]") # defaults to top one (i.e., search)
    end
  end

  describe 'search tip' do
    it 'renders a random search tip' do
      visit articles_path

      within '.home-page-tips' do
        expect(page).to have_css('dt', text: /\S+/)
        expect(page).to have_css('dd', text: /\S+/)
      end
    end
  end

  describe 'Search Settings', js: true do
    before { visit articles_path }

    it 'adds a hidden input for any initial selections' do
      within '#dynamic-hidden-inputs-target', visible: false do
        expect(page).to have_css('input#hidden_eds_limiter_FT1', visible: false)
      end
    end

    it 'adds a hidden input for setting checkboxes that are selected' do
      within '#dynamic-hidden-inputs-target', visible: false do
        expect(page).to have_no_css('input#hidden_eds_limiter_RT', visible: false)
      end

      check 'Limiter1'

      within '#dynamic-hidden-inputs-target', visible: false do
        expect(page).to have_css('input#hidden_eds_limiter_RT', visible: false)
      end
    end

    it 'removes the relevant hidden input for a setting checkbox that is deselected' do
      within '#dynamic-hidden-inputs-target', visible: false do
        expect(page).to have_css('input#hidden_eds_limiter_FT1', visible: false)
      end

      uncheck 'Limiter2'

      within '#dynamic-hidden-inputs-target', visible: false do
        expect(page).to have_no_css('input#hidden_eds_limiter_FT1', visible: false)
      end
    end
  end
end
