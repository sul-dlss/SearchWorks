# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Searchworks4::InclusiveHierarchyFacetFieldComponent, type: :component do
  before do
    render_inline(described_class.new(values:, field_name: 'format_hsim', tree:, key: 'Image'))
  end

  let(:values) { [["Image", "Image|Poster"]] }
  let(:tree) do
    {
      _: HierarchicalFacetItem.new('Image', 'Image', 15),
      Poster: HierarchicalFacetItem.new('Image|Poster', 'Poster', 1)
    }
  end

  it 'has the facet selected for the key value' do
    expect(page).to have_css('span.selected', text: 'Image')
  end

  it 'displays a removal link that includes the other inclusive facet instead' do
    remove_link = Rack::Utils.parse_nested_query(page.find('a.remove')['href']).with_indifferent_access
    expect(remove_link['http://test.host/catalog?f_inclusive']['format_hsim']).to eq(['Image|Poster'])
  end
end
