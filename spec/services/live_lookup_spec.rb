# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LiveLookup do
  subject(:live_lookup) { LiveLookup.new(ids) }

  let(:ids) { ['1234566'] }
  let(:implementation) { instance_double(LiveLookup::Folio, records: [{ barcode: '111' }]) }

  before do
    allow(Settings).to receive(:live_lookup_service).and_return('LiveLookup::Folio')
  end

  it 'creates an instance of LiveLookup::Folio and returns live lookup data' do
    expect(LiveLookup::Folio).to receive(:new).with(ids).and_return(implementation)
    expect(live_lookup.records).to eq([{ barcode: '111' }])
  end

  context 'when there are no ids to look up' do
    let(:ids) { [nil] }

    it 'returns no records without calling the implementation' do
      expect(LiveLookup::Folio).not_to receive(:new)
      expect(live_lookup.records).to eq([])
    end
  end
end
