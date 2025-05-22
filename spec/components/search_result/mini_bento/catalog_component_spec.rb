# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchResult::MiniBento::CatalogComponent, type: :component do
  context 'with q params and non-gallery view' do
    before do
      vc_test_controller.params[:q] = 'question'
      render_inline(described_class.new(close: true))
    end

    it 'draws the page' do
      expect(page).to have_css '[data-alternate-catalog="/articles?f%5Beds_s' \
                               'earch_limiters_facet%5D%5B%5D=Direct+access+to+full+text&q=question"]'
      expect(page).to have_css 'button.btn-close'
      expect(page).to have_css '.alternate-catalog-title'
      expect(page).to have_css '.alternate-catalog-body'
      expect(page).to have_css 'a[href="/articles?f%5Beds_search_limiters_fa' \
                               'cet%5D%5B%5D=Direct+access+to+full+text&q=question"].btn'
      expect(page).to have_css 'ul.alternate-catalog-facets'
    end
  end

  context 'without a q param' do
    before do
      render_inline(described_class.new(close: true))
    end

    it 'draws nothing' do
      expect(page).to have_no_css '*'
    end
  end

  context 'with gallery view' do
    before do
      vc_test_controller.params[:q] = 'question'
      vc_test_controller.params[:view] = 'gallery'
      render_inline(described_class.new(close: true))
    end

    it 'draws nothing' do
      expect(page).to have_no_css '*'
    end
  end
end
