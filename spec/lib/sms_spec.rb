require 'rails_helper'

RSpec.describe "Searchworks::Document::Sms" do
  let(:doc) {
    SolrDocument.new(
      preferred_barcode: '12345',
      item_display_struct: [
        { barcode: '54321', library: 'BIOLOGY', home_location: 'STACKS', temporary_location_code: 'STACKS', type: 'type', truncated_callnumber: 'callnumber1', shelfkey: 'shelfkey', reverse_shelfkey: 'reverse_shelfkey', callnumber: 'callnumber1' },
        { barcode: '12345', library: 'GREEN', home_location: 'GRE-STACKS', temporary_location_code: 'GRE-STACKS', type: 'type', truncated_callnumber: 'callnumber2', shelfkey: 'shelfkey', reverse_shelfkey: 'reverse_shelfkey', callnumber: 'callnumber2' }
      ]
    )
  }
  let(:eds_doc) do
    SolrDocument.new(
      eds_title: 'holla back'
    )
  end

  before(:all) do
    SolrDocument.use_extension(Searchworks::Document::Sms)
  end

  it "returns preferred call number with its library and location" do
    sms_text = doc.to_sms_text
    expect(sms_text).to match(/callnumber2/)
    expect(sms_text).to match(/Green Library - Stacks/)
    expect(sms_text).not_to match(/Biology/)
  end

  context 'eds document' do
    it 'should use the eds title' do
      expect(eds_doc.to_sms_text).to eq 'holla back'
    end
  end
end
