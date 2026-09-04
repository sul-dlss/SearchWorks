# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Searchworks4::MiniMiniBentoComponent, type: :component do
  before do
    allow(vc_test_controller).to receive(:search_state).and_return(search_state)
    render_inline(described_class.new(current_context: current_context))
  end

  let(:search_state) { instance_double(Blacklight::SearchState, query_param: 'cats') }
  let(:current_context) { 'catalog' }

  it 'identifies mini-mini-bento as the analytics source' do
    expect(page).to have_css(
      '.mini-mini-bento[data-controller~="mini-mini-bento"][data-controller~="analytics"]' \
      '[data-analytics-category-value="mini-mini-bento"]'
    )
  end

  it 'tracks clicks on the Articles+ link' do
    expect(page).to have_css('a[data-action="click->analytics#trackLink"]', text: /SearchWorks\s+Articles\+/)
  end

  context 'when rendered for Articles+' do
    let(:current_context) { 'articles' }

    it 'tracks clicks on the catalog link' do
      expect(page).to have_css('a[data-action="click->analytics#trackLink"]', text: /SearchWorks\s+Catalog/)
    end
  end
end
