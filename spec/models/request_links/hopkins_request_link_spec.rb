# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RequestLinks::HopkinsRequestLink do
  let(:item_display_field) do
    ['36105... -|- HOPKINS -|- STACKS -|- ...']
  end
  let(:document) { SolrDocument.new(item_display: item_display_field) }
  let(:library) { 'HOPKINS' }
  let(:location) { 'STACKS' }
  let(:items) { [double(type: 'STKS', current_location: double(code: nil))] }

  subject(:link) { described_class.new(document: document, library: library, location: location, items: items) }

  describe '#present?' do
    context 'when the item is not available online and Hopkins is the only library with holdings' do
      it { expect(link).to be_present }
    end

    context 'when the item is avialable online (via SFX)' do
      let(:document) do
        SolrDocument.new(url_sfx: 'https://library.stanford.edu', item_display: item_display_field)
      end

      it { expect(link).not_to be_present }
    end

    context 'when the item is avialable online (via fulltext link)' do
      let(:document) do
        SolrDocument.new(url_fulltext: 'https://library.stanford.edu', item_display: item_display_field)
      end

      it { expect(link).not_to be_present }
    end

    context 'when the item is avialable online (via hathi public domain)' do
      let(:document) do
        SolrDocument.new(ht_htid_ssim: 'abc123', ht_access_sim: ['allow'], item_display: item_display_field)
      end

      it { expect(link).not_to be_present }
    end

    context 'when the item is available at another library' do
      let(:item_display_field) do
        [
          '361051.. -|- HOPKINS -|- STACKS -|- ...',
          '361052.. -|- GREEN -|- STACKS -|- ...'
        ]
      end

      it { expect(link).not_to be_present }
    end

    describe 'behavior inherited from the RequestLink class' do
      context 'locations' do
        let(:location) { 'LOCKED-STK' }

        it { expect(link).not_to be_present }
      end

      context 'item types' do
        let(:items) { [double(show_item_level_request_link?: false, type: 'NH-INHOUSE', current_location: double(code: nil))] }

        it { expect(link).not_to be_present }
      end

      context 'temporary access' do
        let(:document) { SolrDocument.new(ht_htid_ssim: 'abc123', item_display: item_display_field) }

        it { expect(link).not_to be_present }
      end
    end
  end
end
