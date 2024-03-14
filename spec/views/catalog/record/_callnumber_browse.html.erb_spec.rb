# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "catalog/record/_callnumber_browse" do
  let(:document) {
    SolrDocument.new(
      id: 'abc123',
      browse_nearby_struct: [
        { item_id: 'A', shelfkey: 'shelfkey', reverse_shelfkey: 'reverse_shelfkey', callnumber: 'callnumber', lopped_callnumber: 'callnumber' },
        { item_id: 'B', shelfkey: 'shelfkey2', reverse_shelfkey: 'reverse_shelfkey', callnumber: 'callnumber2', lopped_callnumber: 'callnumber2' }
      ],
      item_display_struct: [
        { id: 'A', barcode: 'barcode', library: 'library', effective_permanent_location_code: 'home_location', temporary_location_code: 'temporary_location_code', type: 'type', lopped_callnumber: 'truncated_callnumber', callnumber: 'callnumber', full_shelfkey: 'full_shelfkey' },
        { id: 'B', barcode: 'barcode2', library: 'library', effective_permanent_location_code: 'home_location', temporary_location_code: 'temporary_location_code', type: 'type', lopped_callnumber: 'truncated_callnumber2', callnumber: 'callnumber2', full_shelfkey: 'full_shelfkey' }
      ]
    )
  }

  before do
    render 'catalog/record/callnumber_browse', document:
  end

  it "should render a panel" do
    expect(rendered).to have_css('div.record-browse-nearby')
    expect(rendered).to have_css(".section#browse-nearby")
  end
  skip "should render browse index links with index url" do
    expect(rendered).to have_link('View full page', href: '/browse?start=full_shelfkey&view=gallery')
    expect(rendered).to have_link('Continue to full page', href: '/browse?start=full_shelfkey&view=gallery')
    # Somehow we need to send in a fixture that will invoke the right ckey
  end
  it "should render a heading" do
    expect(rendered).to have_css('h2', text: /Browse related items/)
  end
  it "should include links to all unique callnumbers" do
    expect(rendered).to have_css('.callnumber button', text: "callnumber")
    expect(rendered).to have_css('.callnumber button', text: "callnumber2")
  end
end
