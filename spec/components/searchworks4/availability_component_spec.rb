# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Searchworks4::AvailabilityComponent, type: :component do
  context 'without holdings or links' do
    let(:document) { SolrDocument.new }

    it 'does not render' do
      render_inline(described_class.new(document: document))

      expect(page).to have_no_css('.availability-component')
    end
  end

  context 'with a single item in Green Stacks' do
    let(:document) { SolrDocument.from_fixture("1391872.yml") }

    it 'renders the item with Green Stacks location' do
      render_inline(described_class.new(document: document))

      aggregate_failures do
        expect(page).to have_css('.availability-component', text: 'Green Library')
        expect(page).to have_link('Stacks', href: %r{^/view/1391872/stackmap})
        expect(page).to have_css('.callnumber', text: 'KKX3800 .H49 1973')
      end
    end
  end

  context 'with multiple items all in Green Stacks' do
    let(:document) { SolrDocument.from_fixture("10678312.yml") }

    it 'renders all items with Green Stacks location', :js do
      render_inline(described_class.new(document: document))

      aggregate_failures do
        expect(page).to have_css('.availability-component', text: 'Green Library')
        expect(page).to have_link('Stacks', href: %r{^/view/10678312/stackmap})
        expect(page).to have_css('.rounded-pill', text: '4 items')
        expect(page).to have_css('summary', text: 'Show details')

        expect(page).to have_no_css('.callnumber', visible: :visible)
      end

      expect(page).to have_css('.callnumber', text: 'F2161 .E27 2014', count: 4, visible: :all)
    end
  end

  context 'with an online link' do
    let(:document) { SolrDocument.from_fixture("in00000444367.yml") }

    it 'renders the online link' do
      render_inline(described_class.new(document: document))

      expect(page).to have_css('.availability-component', text: 'Available online').and(have_link('Naxos Music Library', href: /stanford.idm.oclc.org/))
    end
  end
end
