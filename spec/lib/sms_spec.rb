require 'spec_helper'

RSpec.describe "Searchworks::Document::Sms" do
  let(:doc) {
    SolrDocument.new(
      preferred_barcode: '12345',
      item_display: [
        '54321 -|- BIOLOGY -|- STACKS -|-  -|- -|- -|- -|- -|- callnumber1 -|- 1',
        '12345 -|- GREEN -|- STACKS -|-  -|- -|- -|- -|- -|- callnumber2 -|- 2'
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
