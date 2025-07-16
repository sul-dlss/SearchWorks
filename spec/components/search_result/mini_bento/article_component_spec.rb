# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchResult::MiniBento::ArticleComponent, type: :component do
  before do
    vc_test_controller.params[:q] = 'question'
    render_inline(described_class.new)
  end

  it 'draws the page' do
    expect(page).to have_css 'button.btn-close'
    expect(page).to have_css '.alternate-catalog-title'
    expect(page).to have_css '.alternate-catalog-body'
    expect(page).to have_css 'a[href="/catalog?q=question"].btn'
  end
end
