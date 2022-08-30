require "spec_helper"

describe SolrHoldings do
  let(:document) { SolrDocument.new }

  it "should provide a holdings method" do
    expect(document).to respond_to(:holdings)
    expect(document.holdings).to be_a Holdings
  end

  describe '#preferred_barcode' do
    let(:preferred) {
      SolrDocument.new(
        preferred_barcode: '12345',
        item_display: [
          '54321 -|- GREEN -|- STACKS -|-  -|- -|- -|- -|- -|- callnumber1 -|- 1',
          '12345 -|- GREEN -|- STACKS -|-  -|- -|- -|- -|- -|- callnumber2 -|- 2'
        ]
      )
    }
    let(:bad_preferred) {
      SolrDocument.new(
        preferred_barcode: 'does-not-exist',
        item_display: [
          '54321 -|- GREEN -|- STACKS -|-  -|- -|- -|- -|- -|- callnumber1 -|- 1',
          '12345 -|- GREEN -|- STACKS -|-  -|- -|- -|- -|- -|- callnumber2 -|- 2'
        ]
      )
    }
    let(:no_preferred) {
      SolrDocument.new(
        item_display: [
          '54321 -|- GREEN -|- STACKS -|-  -|- -|- -|- -|- -|- callnumber1 -|- 1',
          '12345 -|- GREEN -|- STACKS -|-  -|- -|- -|- -|- -|- callnumber2 -|- 2'
        ]
      )
    }

    it 'should return the item based on preferred barcode' do
      expect(preferred.preferred_item.barcode).to eq '12345'
    end
    it 'should return the first item when the preferred barcode does not exist in the holdings' do
      expect(bad_preferred.preferred_item.barcode).to eq '54321'
    end
    it 'should return the first item if there is no preferred barcode available' do
      expect(no_preferred.preferred_item.barcode).to eq '54321'
    end
  end
end
