# frozen_string_literal: true

require "rails_helper"

RSpec.describe Articles::Response::LimitedFacetFieldListComponent, type: :component do
  before do
    render_inline(described_class.new(facet_field: facet_field))
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
      values: [],
      item_presenter: instance_double(Blacklight::FacetItemPresenter, href: '', selected?: false, label: 'Field', hits: 0, value: 'field_value')
    )
  end

  let(:facet_config) { Blacklight::Configuration::NullField.new(key: 'field', item_component: Blacklight::FacetItemComponent, item_presenter: Blacklight::FacetItemPresenter) }

  context 'with fewer than 20 facet_values' do
    let(:paginator) do
      instance_double(Blacklight::FacetPaginator, items: [
        double(label: 'x', hits: 10),
        double(label: 'y', hits: 33)
      ])
    end

    it 'renders the facet items' do
      expect(page).to have_css '[data-controller="articles-facet-more"]'
      expect(page).to have_css 'ul.facet-values'
      expect(page).to have_css 'li', count: 2
      expect(page).to have_no_link "more"
    end
  end

  context 'with more than 20 facet_values' do
    let(:paginator) do
      instance_double(Blacklight::FacetPaginator, items: Array.new(25) { double(label: 'x', hits: 10) })
    end

    it 'renders the facet items' do
      expect(page).to have_css '[data-controller="articles-facet-more"]'
      expect(page).to have_css 'ul.facet-values'
      expect(page).to have_css 'li', count: 8
      expect(page).to have_css 'li', count: 25, visible: :all # some are hidden
      expect(page).to have_link "Browse all"
    end
  end
end
