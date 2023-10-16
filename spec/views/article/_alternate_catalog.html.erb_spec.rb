# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'articles/_alternate_catalog' do
  before do
    controller.params[:q] = 'question'
    stub_template '_lib_guides_alternate_catalog' => ''
    render
  end

  it 'has data-attributes' do
    expect(rendered).to have_css '[data-alternate-catalog="/catalog?q=question"]'
  end
  it 'has a close button' do
    expect(rendered).to have_css 'button.close'
  end
  it 'has a title' do
    expect(rendered).to have_css '.alternate-catalog-title'
  end
  it 'has a body' do
    expect(rendered).to have_css '.alternate-catalog-body'
  end
  it 'has a link to search' do
    expect(rendered).to have_css 'a[href="/catalog?q=question"].btn'
  end
  it 'has a facet section' do
    expect(rendered).to have_css '.alternate-catalog-facet-section'
  end
  it 'has a ul li for facets' do
    expect(rendered).to have_css 'ul.alternate-catalog-facets'
  end
end
