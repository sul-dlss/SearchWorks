# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Searchworks4::ItemStatusComponent, type: :component do
  context 'with an available, circulating item' do
    let(:item) do
      Holdings::Item.new({ id: 'someuuid', status: 'Available' })
    end

    before do
      allow(item).to receive(:circulates?).and_return(true)
    end

    it 'renders an RTAC placeholder if the item is available' do
      render_inline(described_class.new(item: item))

      aggregate_failures do
        expect(page).to have_css('#availability_item_someuuid')
        expect(page).to have_css('.placeholder-wave .likely-available')
      end
    end
  end

  context 'with an available, circulating item after fetching the RTAC data' do
    let(:item) do
      Holdings::Item.new({ id: 'someuuid', status: 'Available' })
    end

    let(:rtac) do
      { status: 'Available' }
    end

    before do
      allow(item).to receive(:circulates?).and_return(true)
    end

    it 'renders the available status' do
      render_inline(described_class.new(item: item, rtac: rtac))

      aggregate_failures do
        expect(page).to have_css('#availability_item_someuuid_rtac')
        expect(page).to have_css('.availability', text: 'Available')
      end
    end
  end

  context 'with an available, circulating item that turns out to be checked out after fetching the RTAC data' do
    let(:item) do
      Holdings::Item.new({ id: 'someuuid', status: 'Available' }, document: SolrDocument.new(id: '123'))
    end

    let(:rtac) do
      { status: 'Checked out' }
    end

    before do
      allow(item).to receive_messages(circulates?: true, allowed_request_types: %w[Hold], folio_item?: true)
    end

    it 'renders the checked out status and request link' do
      render_inline(described_class.new(item: item, rtac: rtac))

      aggregate_failures do
        expect(page).to have_css('#availability_item_someuuid_rtac')
        expect(page).to have_css('.availability', text: 'Checked out')
        expect(page).to have_link('Request')
      end
    end
  end

  context 'with a missing item' do
    let(:item) do
      Holdings::Item.new({ id: 'someuuid', status: 'Missing' }, document: SolrDocument.new(id: '123'))
    end

    before do
      allow(item).to receive_messages(circulates?: true, allowed_request_types: %w[Hold], folio_item?: true)
    end

    it 'renders the status and request button (but no placeholder, because the item status probably did not change)' do
      render_inline(described_class.new(item: item))

      aggregate_failures do
        expect(page).to have_css('#availability_item_someuuid')
        expect(page).to have_css('.availability', text: 'Missing')
        expect(page).to have_link('Request')
      end
    end
  end

  context 'with a loan period' do
    let(:item) do
      Holdings::Item.new({ id: 'someuuid', status: 'Available', course_id: '123', loan_period: '3 weeks' })
    end

    it 'renders the loan period in the status' do
      render_inline(described_class.new(item: item))
      expect(page).to have_css('.availability', text: 'Available 3 weeks')
    end
  end

  context 'with a temporary location' do
    let(:item) do
      Holdings::Item.new({ id: 'someuuid', status: 'Available', temporary_location_code: 'GRE-HH-EXHIBIT' })
    end

    it 'renders the temporary location instead of the status' do
      render_inline(described_class.new(item: item))

      aggregate_failures do
        expect(page).to have_css('#availability_item_someuuid')
        expect(page).to have_no_css('.availability', text: 'Available')
        expect(page).to have_css('.temporary-location', text: 'Hohbach Hall: Exhibits')
      end
    end
  end

  context 'with a temporary location that implies a status' do
    let(:item) do
      Holdings::Item.new({ id: 'someuuid', status: 'Available', temporary_location_code: 'MUS-INPROCESS' })
    end

    it 'renders the effective status from the temporary location' do
      render_inline(described_class.new(item: item))

      aggregate_failures do
        expect(page).to have_css('#availability_item_someuuid')
        expect(page).to have_no_css('.availability', text: 'In Process')
      end
    end
  end

  context 'with item of unknown availability status and individual volumes cataloged separately' do
    let(:item) do
      Holdings::Item.new({ status: 'Unknown', barcode: '001AKH1250' }, document: document)
    end
    let(:document) { SolrDocument.from_fixture("2027166.yml") }

    it 'renders the See volumes link for the volumes modal' do
      render_inline(described_class.new(item: item))

      expect(page).to have_link('See volumes')
    end
  end
end
