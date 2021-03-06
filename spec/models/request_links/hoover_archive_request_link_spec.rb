# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RequestLinks::HooverArchiveRequestLink do
  let(:document) do
    SolrDocument.new(
      url_suppl: ['http://oac.cdlib.org/ark:/abc123']
    )
  end
  let(:library) { 'HV-ARCHIVE' }
  let(:location) { 'STACKS' }
  let(:items) { [] }

  subject(:link) { described_class.new(document: document, library: library, location: location, items: items) }

  describe '#present?' do
    # Always render links for Hoover Archive
    it { expect(link).to be_present }
  end

  describe '#url' do
    context 'when available via temporary access' do
      let(:document) do
        SolrDocument.new(
          url_suppl: ['http://oac.cdlib.org/ark:/abc123'],
          ht_htid_ssim: 'abc123'
        )
      end

      it { expect(link.url).not_to be_present }
    end

    context 'when not available via temporary access' do
      it 'is the finding aid link' do
        expect(link.url).to eq 'http://oac.cdlib.org/ark:/abc123'
      end
    end
  end

  describe '#render' do
    let(:rendered) { Capybara.string(link.render) }

    context 'when a finding aid is present' do
      it 'renders a link w/ custom link text' do
        expect(rendered).to have_link('Request via Finding Aid', href: 'http://oac.cdlib.org/ark:/abc123')
      end
    end

    context 'when a finding aid is not present' do
      let(:document) { SolrDocument.new }

      it 'renders text indicating the item is not requestable' do
        expect(rendered).not_to have_link
        expect(rendered).to have_content 'Not available to request'
      end
    end
  end
end
