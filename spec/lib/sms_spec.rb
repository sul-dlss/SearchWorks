# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Searchworks::Document::Sms" do
  let(:doc) {
    SolrDocument.new(
      preferred_barcode: '12345',
      item_display_struct: [
        { barcode: '54321', library: 'BIOLOGY', effective_permanent_location_code: 'STACKS', temporary_location_code: 'STACKS', type: 'type',
          truncated_callnumber: 'callnumber1', callnumber: 'callnumber1' },
        { barcode: '12345', library: 'GREEN', effective_permanent_location_code: 'GRE-STACKS', temporary_location_code: 'GRE-STACKS', type: 'type',
          truncated_callnumber: 'callnumber2', callnumber: 'callnumber2' }
      ]
    )
  }
  let(:eds_doc) do
    StubArticleService.full_text_document
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
    it 'uses the eds title' do
      expect(eds_doc.to_sms_text).to eq 'The title of the document'
    end
  end
end
