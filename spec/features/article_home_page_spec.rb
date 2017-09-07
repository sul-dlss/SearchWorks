require 'spec_helper'

feature 'Article Home Page' do
  before do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
    visit articles_path
  end

  it 'has the correct title' do
    expect(page).to have_title('SearchWorks articles+ : Stanford Libraries')
  end

  it 'has fielded search' do
    within '#search_field' do
      %w[search author title subject source abstract issn isbn].each do |search_field|
        expect(page).to have_css("option[value=\"#{search_field}\"]")
      end
      expect(page).not_to have_css("option[selected]") # defaults to top one (i.e., search)
    end
  end

  describe 'search tip' do
    it 'renders a random search tip' do
      within '.home-page-tips' do
        expect(page).to have_css('dt', text: /\S+/)
        expect(page).to have_css('dd', text: /\S+/)
      end
    end
  end

  describe 'Search Settings', js: true do
    it 'adds a hidden input for any initial selections' do
      within '#dynamic-hidden-inputs-target' do
        expect(page).to have_css('input#hidden_eds_limiter_FT1', visible: false)
      end
    end

    it 'adds a hidden input for setting checkboxes that are selected' do
      within '#dynamic-hidden-inputs-target' do
        expect(page).not_to have_css('input#hidden_eds_limiter_RT', visible: false)
      end

      check 'Limiter1'

      within '#dynamic-hidden-inputs-target' do
        expect(page).to have_css('input#hidden_eds_limiter_RT', visible: false)
      end
    end

    it 'removes the relevant hidden input for a setting checkbox that is deselected' do
      within '#dynamic-hidden-inputs-target' do
        expect(page).to have_css('input#hidden_eds_limiter_FT1', visible: false)
      end

      uncheck 'Limiter2'

      within '#dynamic-hidden-inputs-target' do
        expect(page).not_to have_css('input#hidden_eds_limiter_FT1', visible: false)
      end
    end
  end
end
