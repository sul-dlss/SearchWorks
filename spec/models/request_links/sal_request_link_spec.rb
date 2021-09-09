# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RequestLinks::SalRequestLink do
  subject(:link) do
    described_class.new(document: document, library: 'SAL3', location: location, items: items)
  end

  let(:location) { 'STACKS' }
  let(:items) { [double(must_request?: false, type: 'STKS-MONO', current_location: double(code: nil))] }

  describe '#show_location_level_request_link?' do
    context 'when an ETAS item is scannable' do
      let(:document) { SolrDocument.new(ht_htid_ssim: 'abc123') }

      it { expect(link).to be_show_location_level_request_link }
    end

    context 'when an ETAS item is not scannable' do
      let(:location) { 'LOCKED-STK' }
      let(:document) { SolrDocument.new(ht_htid_ssim: 'abc123') }

      it { expect(link).not_to be_show_location_level_request_link }
    end
  end

  describe '#scannable?' do
    let(:document) { SolrDocument.new }

    context 'when a scannable item typed item is in a scannable library/location' do
      it { expect(link.send(:scannable?)).to be true }
    end

    context 'when a non-scannable item typed item is in a scannable library/location' do
      let(:items) { [double(must_request?: false, type: 'NEWSPAPER', current_location: double(code: nil))] }

      it { expect(link.send(:scannable?)).to be false }
    end

    context 'when an item has a location that has its own list of scannable item types' do
      let(:location) { 'PAGE-GR' }
      let(:items) { [double(must_request?: false, type: 'NEWSPAPER', current_location: double(code: nil))] }

      it { expect(link.send(:scannable?)).to be true }
    end
  end
end
