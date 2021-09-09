# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RequestLinks::HooverRequestLink do
  include MarcMetadataFixtures

  let(:document) { SolrDocument.new(marcxml: metadata1) }
  let(:library) { 'HOOVER' }
  let(:location) { 'STACKS' }
  let(:items) { [] }

  subject(:link) { described_class.new(document: document, library: library, location: location, items: items) }

  describe '#show_location_level_request_link?' do
    context 'when available via temporary access' do
      let(:document) { SolrDocument.new(marcxml: metadata1, ht_htid_ssim: 'abc123') }

      it { expect(link).not_to be_show_location_level_request_link }
    end

    context 'when not available via temporary access' do
      it { expect(link).to be_show_location_level_request_link }
    end
  end

  describe '#url' do
    it 'is the HooverOpenUrl' do
      expect(link.url).to start_with(Settings.HOOVER_REQUESTS_URL)
    end
  end

  describe '#render' do
    let(:rendered) { Capybara.string(link.render) }

    it 'renders custom link text' do
      expect(rendered).to have_link('Request on-site access')
    end

    it 'includes custom tooltip markup' do
      rendered_link = rendered.find('a')
      expect(rendered_link['data-toggle']).to eq 'tooltip'
      expect(rendered_link['data-title']).to start_with 'Requires Aeon signup'
    end
  end
end
