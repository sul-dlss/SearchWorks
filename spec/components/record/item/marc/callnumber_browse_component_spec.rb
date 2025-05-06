# frozen_string_literal: true

require "rails_helper"

RSpec.describe Record::Item::Marc::CallnumberBrowseComponent, type: :component do
  let(:component) { described_class.new(document:) }
  let(:document) {
    SolrDocument.new(
      id: 'abc123',
      browse_nearby_struct: [
        { item_id: 'A', shelfkey: 'shelfkey', reverse_shelfkey: 'reverse_shelfkey', callnumber: 'callnumber', lopped_callnumber: 'callnumber' },
        { item_id: 'B', shelfkey: 'shelfkey2', reverse_shelfkey: 'reverse_shelfkey', callnumber: 'callnumber2', lopped_callnumber: 'callnumber2' }
      ],
      item_display_struct: [
        { barcode: 'barcode', library: 'library', effective_permanent_location_code: 'location_code', temporary_location_code: 'temporary_location_code', type: 'type',
          lopped_callnumber: 'truncated_callnumber', callnumber: 'callnumber', full_shelfkey: 'full_shelfkey' },
        { barcode: 'barcode2', library: 'library', effective_permanent_location_code: 'location_code', temporary_location_code: 'temporary_location_code', type: 'type',
          lopped_callnumber: 'truncated_callnumber2', callnumber: 'callnumber2', full_shelfkey: 'full_shelfkey' }
      ]
    )
  }

  before do
    render_inline(component)
  end

  it "renders the component" do
    expect(page).to have_css('button.collapsed[data-behavior="embed-browse"][data-embed-viewport="#callnumber-1"][data-start="abc123"]', text: 'callnumber')
    expect(page).to have_css('div.record-browse-nearby')
    expect(page).to have_css(".section#browse-nearby")
    expect(page).to have_css('h2', text: /Browse related items/)
    expect(page).to have_css('.btn-callnumber', text: "callnumber")
    expect(page).to have_css('.btn-callnumber', text: "callnumber2")
  end
end
