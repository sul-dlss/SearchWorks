# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RequestLink do
  subject(:link) { described_class.new(document: document, library: library, location: location, items: items) }

  let(:document) { SolrDocument.new(id: '12345') }
  let(:library) { 'GREEN' }
  let(:location) { 'LOCKED-STK' }
  let(:items) { [double(type: 'STKS-MONO', current_location: double(code: nil))] }

  describe '#present?' do
    context 'for libaries/locations that are configured to have request links' do
      it { expect(link).to be_present }
    end

    context 'for libaries that are not configured to have request links' do
      let(:library) { 'CLASSICS' }

      it { expect(link).not_to be_present }
    end

    context 'for locations that not configured to have request links' do
      let(:location) { 'IC-NEWSPAPER' }

      it { expect(link).not_to be_present }
    end

    context 'when none of the items have a circulating type ' do
      let(:items) { [double(type: 'NONCIRC', current_location: double(code: nil))] }

      it { expect(link).not_to be_present }
    end

    context 'when available under a temporary access agreement' do
      let(:document) { SolrDocument.new(ht_htid_ssim: 'abc123') }

      it { expect(link).not_to be_present }
    end

    context 'when an item is in a library that wildcards item types' do
      let(:library) { 'SPEC-COLL' }
      let(:items) { [double(type: 'NONCIRC', current_location: double(code: nil))] }

      it { expect(link).to be_present }
    end

    context 'when an item is in a location that wildcards item types' do
      let(:library) { 'ART' }
      let(:location) { 'ARTLCKL' }
      let(:items) { [double(type: 'NONCIRC', current_location: double(code: nil))] }

      it { expect(link).to be_present }
    end

    context 'when an item is in a non wildcarded location within a library that specifies location specific item types' do
      let(:library) { 'ART' }
      let(:location) { 'STACKS' }
      let(:items) { [double(type: 'NONCIRC', current_location: double(code: nil))] }

      it { expect(link).not_to be_present }
    end

    context 'when a library has its locations wildcarded' do
      let(:library) { '???' }
      let(:location) { 'UNKNOWN-LOCATION' }

      # We don't have this case yet, but here's the test if we ever do
      pending { expect(link).to be_present }
    end

    context 'when all items are in a disallowed current location' do
      let(:library) { 'SPEC-COLL' }
      let(:items) { [double(type: 'STKS-MONO', current_location: double(code: 'SPEC-INPRO'))] }

      it { expect(link).not_to be_present }
    end
  end

  describe '#render' do
    context 'when not present' do
      let(:location) { 'IC-NEWSPAPER' }

      it { expect(link.render).to eq '' }
    end

    context 'when present' do
      it 'renders the #markup as html_safe' do
        expect(link.render).to match(/<a .*>Request.*<\/a>/)
      end
    end
  end

  describe '#url' do
    it 'appends the request app params to the base URL' do
      expect(link.url).to start_with(Settings.REQUESTS_URL)
      expect(link.url).to include('item_id=12345')
      expect(link.url).to include('origin=GREEN')
      expect(link.url).to include('origin_location=LOCKED-STK')
    end
  end
end
