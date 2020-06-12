# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RequestLinks::SsrcDataRequestLink do
  let(:document) { SolrDocument.new(id: 'abc123', title_display: 'The title of the document') }
  let(:library) { 'GREEN' }
  let(:location) { 'SSRC-DATA' }
  let(:items) { [double(callnumber: 'AB12 .c3')] }

  subject(:link) { described_class.new(document: document, library: library, location: location, items: items) }

  describe '#present?' do
    # SSRC-DATA Request links are always present for items in that location
    it { expect(link).to be_present }
  end

  describe '#url' do
    it 'includes the document ID' do
      expect(link.url).to include '&unicorn_id_in=abc123'
    end

    it 'includes the callnumber' do
      expect(link.url).to include '&call_no_in=AB12+.c3'
    end

    it 'includes the document title' do
      expect(link.url).to include '&title_in=The+title+of+the+document'
    end

    it 'includes blank URL parameters required by the form' do
      expect(link.url).to include 'authid=&'
      expect(link.url).to include 'icpsr_no_in=&'
    end
  end

  describe '#render' do
    it 'renders a link w/ the appropriate text' do
      expect(Capybara.string(link.render)).to have_link('Request')
    end
  end
end
