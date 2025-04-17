# frozen_string_literal: true

require "rails_helper"

RSpec.describe Articles::Response::FacetItemComponent, type: :component do
  before do
    render_inline(described_class.new(facet_item: facet_item, hidden:))
  end

  let(:hidden) { false }

  let(:facet_item) do
    instance_double(
      Blacklight::FacetItemPresenter,
      facet_config: Blacklight::Configuration::FacetField.new,
      label: 'x',
      hits: 10,
      href: '/catalog?f=x',
      selected?: false
    )
  end

  it 'links to the facet and shows the number of hits' do
    expect(page).to have_css 'li'
    expect(page).to have_link 'x', href: '/catalog?f=x' do |link|
      link['rel'] == 'nofollow'
    end
    expect(page).to have_css '.facet-count', text: '10'
  end

  context 'with a hidden value' do
    let(:hidden) { true }

    it 'is hidden' do
      expect(page).to have_css 'li', visible: :hidden
    end
  end
end
