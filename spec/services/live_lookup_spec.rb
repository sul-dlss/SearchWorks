require "spec_helper"

describe LiveLookup do
  subject(:live_lookup) { LiveLookup.new(ids) }

  let(:ids) { ['1234566'] }
  let(:sirsi_lookup) { instance_double(LiveLookup::Sirsi) }

  before do
    allow(sirsi_lookup).to receive(:records).and_return([{ barcode: '111' }])
  end

  it 'creates an instance of LiveLookup::Sirsi and returns live lookup data' do
    expect(LiveLookup::Sirsi).to receive(:new).with(ids).and_return(sirsi_lookup)
    expect(live_lookup.records).to eq([{ barcode: '111' }])
  end
end
