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
        expect(page).to have_css('turbo-frame[src="/availability/1391872"]')
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

      expect(page).to have_css('turbo-frame[src="/availability/10678312"][loading="lazy"]', visible: :all)
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

  context 'with a physical item and an online link' do
    let(:document) { SolrDocument.from_fixture("10838998.yml") }

    it 'renders both the physical item and the online link' do
      render_inline(described_class.new(document: document))

      aggregate_failures do
        expect(page).to have_css('.availability-component', text: 'Available online')
        expect(page).to have_link('MIT Press Direct', href: /stanford.idm.oclc.org/)
        expect(page).to have_css('.availability-component', text: '2 items')

        expect(page).to have_css('turbo-frame[src="/availability/10838998"][loading="lazy"]', visible: :all)
        expect(page).to have_css('table caption', text: '1 item in Green Library Stacks', visible: :all)
        expect(page).to have_css('table caption', text: '1 item in Music Library Stacks', visible: :all)
      end
    end
  end

  context 'with a large number of items' do
    subject(:component) { described_class.new(document: document) }

    let(:document) { SolrDocument.from_fixture("402381.yml") }

    before do
      allow_any_instance_of(Searchworks4::PhysicalAvailabilityComponent).to receive(:link_to_document).and_return('See availability') # rubocop:disable RSpec/AnyInstance
    end

    it 'renders the item count and details' do
      render_inline(component)

      expect(page).to have_no_css('turbo-frame[src="/availability/402381"]')
      expect(page).to have_css('.availability-component', text: '30 items')
      expect(page).to have_text('See availability')
    end
  end

  context 'with a single item with an MHLD somewhere else' do
    let(:document) { SolrDocument.from_fixture("513384.yml") }

    it 'renders the pill with the item count' do
      render_inline(described_class.new(document: document))

      expect(page).to have_css('.availability-component', text: '1 item')
      expect(page).to have_css('table caption', text: '1 item in SAL3', visible: :all)
    end

    it 'renders the MHLD data' do
      pending 'Not currently rendering the MHLD data'
      render_inline(described_class.new(document: document))

      expect(page).to have_css('table caption', text: 'Library has: 1972/76', visible: :all)
    end
  end
end
