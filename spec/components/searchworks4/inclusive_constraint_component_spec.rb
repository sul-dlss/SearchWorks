# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Searchworks4::InclusiveConstraintComponent, type: :component do
  before do
    render_inline(described_class.new(facet_field: facet_field))
  end

  let(:facet_config) { Blacklight::Configuration::NullField.new(key: 'field', item_component: Blacklight::Facets::ItemComponent, item_presenter: Blacklight::FacetItemPresenter) }

  let(:paginator) do
    instance_double(Blacklight::FacetPaginator, items: [
      Blacklight::Solr::Response::Facets::FacetItem.new(value: 'a', label: 'a', hits: 10),
      Blacklight::Solr::Response::Facets::FacetItem.new(value: 'b', label: 'b', hits: 20),
      Blacklight::Solr::Response::Facets::FacetItem.new(value: 'c', label: 'c', hits: 30)
    ])
  end

  let(:facet_field) do
    instance_double(
      Blacklight::FacetFieldPresenter,
      paginator: paginator,
      facet_field: facet_config,
      key: 'field',
      label: 'Field',
      active?: false,
      collapsed?: false,
      modal_path: nil,
      values: [%w[a b]],
      search_state: search_state
    )
  end

  let(:blacklight_config) do
    Blacklight::Configuration.new.configure do |config|
      config.add_facet_field :field
    end
  end
  let(:search_state) { Blacklight::SearchState.new(params.with_indifferent_access, blacklight_config) }
  let(:params) { { f_inclusive: { field: %w[a b] } } }

  it 'renders heading for inclusive constraints' do
    expect(page).to have_css('span.advanced-facet-heading', text: 'Includes ANY')
  end

  it 'displays selected facets correctly' do
    expect(page).to have_css('li span.selected', text: 'a')
    expect(page).to have_css('li span.selected', text: 'b')
  end

  it 'displays facet not included without selection' do
    expect(page).to have_css('li a.facet-select', text: 'c')
    expect(page).to have_no_css('li span.selected', text: 'c')
  end

  it 'displays removal links for selected facets' do
    a_remove = page.find('span.selected', text: 'a').find('+a.remove')
    b_remove = page.find('span.selected', text: 'b').find('+a.remove')
    expect(CGI.unescape(a_remove['href'])).to eq('http://test.host/catalog?f_inclusive[field][]=b')
    expect(CGI.unescape(b_remove['href'])).to eq('http://test.host/catalog?f_inclusive[field][]=a')
  end
end
