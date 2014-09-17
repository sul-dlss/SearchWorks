require 'spec_helper'

describe "Blacklight::Solr::Document::Sms" do
  let(:doc) {
    SolrDocument.new(
      preferred_barcode: '12345',
      item_display: [
        '54321 -|- BIOLOGY -|- STACKS -|-  -|- -|- -|- -|- -|- callnumber1 -|- 1',
        '12345 -|- GREEN -|- STACKS -|-  -|- -|- -|- -|- -|- callnumber2 -|- 2'
      ]
    )
  }

  before(:all) do
    SolrDocument.use_extension(Blacklight::Solr::Document::Sms)
  end

  it "should return preferred call number with its library and location" do
    sms_text = doc.to_sms_text
    expect(sms_text).to match(/callnumber2/)
    expect(sms_text).to match(/Green Library - Stacks/)
    expect(sms_text).to_not match(/Biology Library (Falconer) - Stacks/)
  end

end
