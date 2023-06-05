require 'spec_helper'

RSpec.describe LocationRequestLinkComponent, type: :component do
  include MarcMetadataFixtures

  subject(:component) { described_class.for(document:, library:, location:, items:) }

  let(:document) { SolrDocument.new(id: '12345') }
  let(:library) { 'GREEN' }
  let(:location) { 'LOCKED-STK' }
  let(:items) { [instance_double(Holdings::Item, current_location: instance_double(Holdings::Location, code: nil), circulates?: true, folio_item?: false)] }

  let(:page) { render_inline(component) }

  context 'for libaries/locations that are configured to have request links' do
    let(:library) { 'GREEN' }
    let(:location) { 'LOCKED-STK' }

    it { expect(page).to have_link 'Request', href: 'https://host.example.com/requests/new?item_id=12345&origin=GREEN&origin_location=LOCKED-STK' }
  end

  context 'for libraries that are not configured to have request links' do
    let(:library) { 'CLASSICS' }
    let(:location) { 'LOCKED-STK' }

    it { expect(page).not_to have_link }
  end

  context 'for locations that not configured to have request links' do
    let(:library) { 'GREEN' }
    let(:location) { 'IC-NEWSPAPER' }

    it { expect(page).not_to have_link }
  end

  context 'when none of the items have a circulating type' do
    let(:items) { [instance_double(Holdings::Item, circulates?: false, current_location: instance_double(Holdings::Location, code: nil), folio_item?: false)] }

    it { expect(page).not_to have_link }
  end

  context 'when all items are in a mediated page location' do
    let(:library) { 'ART' }
    let(:location) { 'ARTLCKL' }
    let(:items) { [instance_double(Holdings::Item, circulates?: false, current_location: instance_double(Holdings::Location, code: nil), folio_item?: false)] }

    it { expect(page).to have_link 'Request' }
  end

  context 'when all items are in an Aeon library' do
    let(:library) { 'SPEC-COLL' }
    let(:items) { [instance_double(Holdings::Item, circulates?: false, current_location: instance_double(Holdings::Location, code: nil), folio_item?: false)] }

    it { expect(page).to have_link 'Request via Aeon' }
  end

  context 'when all items are in an Aeon library but not an Aeon location' do
    let(:library) { 'ARS' }
    let(:location) { 'REFERENCE' }
    let(:items) { [instance_double(Holdings::Item, circulates?: false, current_location: instance_double(Holdings::Location, code: nil), folio_item?: false)] }

    it { expect(page).not_to have_link 'Request via Aeon' }
  end

  context 'when all items are in an Aeon library and location' do
    let(:library) { 'ARS' }
    let(:location) { 'RECORDINGS' }
    let(:items) { [instance_double(Holdings::Item, circulates?: false, current_location: instance_double(Holdings::Location, code: nil), folio_item?: false)] }

    it { expect(page).to have_link 'Request via Aeon' }
  end

  context 'when all items match a combination of Aeon location and item type' do
    let(:document) { SolrDocument.new(id: '12345') }
    let(:library) { 'SAL' }
    let(:location) { 'L-PAGE-EA' }
    let(:items) { [instance_double(Holdings::Item, circulates?: false, type: 'NH-INHOUSE', current_location: instance_double(Holdings::Location, code: nil), folio_item?: false)] }

    it { expect(page).to have_link 'Request via Aeon' }
  end

  context 'when items match an Aeon location but have the wrong item type' do
    let(:document) { SolrDocument.new(id: '12345') }
    let(:library) { 'SAL' }
    let(:location) { 'L-PAGE-EA' }
    let(:items) { [instance_double(Holdings::Item, circulates?: false, type: 'NEWSPAPER', current_location: instance_double(Holdings::Location, code: nil), folio_item?: false)] }

    it { expect(page).not_to have_link 'Request via Aeon' }
  end

  context 'when all items are in a disallowed current location' do
    let(:library) { 'SPEC-COLL' }
    let(:items) { [instance_double(Holdings::Item, circulates?: true, current_location: instance_double(Holdings::Location, code: 'SPEC-INPRO'), folio_item?: false)] }

    it { expect(page).not_to have_link }
  end

  context 'for Hoover Archive items with finding aids' do
    let(:document) do
      SolrDocument.new(
        marc_links_struct: [{ href: "http://oac.cdlib.org/ark:/abc123", finding_aid: true }]
      )
    end
    let(:library) { 'HV-ARCHIVE' }
    let(:location) { 'STACKS' }
    let(:items) { [] }

    it { expect(page).to have_link 'Request via Finding Aid', href: 'http://oac.cdlib.org/ark:/abc123' }
  end

  context 'for Hoover Archive items without finding aids' do
    let(:document) do
      SolrDocument.new
    end
    let(:library) { 'HV-ARCHIVE' }
    let(:location) { 'STACKS' }
    let(:items) { [] }

    it { expect(page).to have_content 'Not available to request' }
  end

  context 'for Hoover Library items' do
    let(:document) { SolrDocument.new(marcxml: metadata1) }
    let(:library) { 'HOOVER' }
    let(:location) { 'STACKS' }

    it { expect(page).to have_link 'Request via Aeon', href: /hoover.aeon.atlas-sys.com/ }

    it 'includes custom tooltip markup' do
      rendered_link = page.css(:a).first
      expect(rendered_link['data-toggle']).to eq 'tooltip'
      expect(rendered_link['data-title']).to start_with 'Requires Aeon signup'
    end
  end

  context 'for Hopkins items' do
    let(:document) do
      SolrDocument.new(item_display: item_display_field)
    end
    let(:library) { 'HOPKINS' }
    let(:location) { 'STACKS' }
    let(:items) { [instance_double(Holdings::Item, circulates?: true, current_location: instance_double(Holdings::Location, code: nil), folio_item?: false)] }
    let(:item_display_field) do
      [
        '361051.. -|- HOPKINS -|- STACKS -|- ...'
      ]
    end

    it { expect(page).to have_link 'Request' }

    context 'when the item is also available via SFX' do
      let(:document) do
        SolrDocument.new(
          item_display: item_display_field,
          marc_links_struct: [{ href: "https://library.stanford.edu", sfx: true }]
        )
      end

      it { expect(page).not_to have_link }
    end

    context 'when the full text is also available' do
      let(:document) do
        SolrDocument.new(
          marc_links_struct: [{ href: "https://library.stanford.edu", fulltext: true }],
          item_display: item_display_field
        )
      end

      it { expect(page).not_to have_link }
    end

    context 'when the item is also available via hathitrust' do
      let(:document) do
        SolrDocument.new(ht_htid_ssim: 'abc123', ht_access_sim: ['allow'], item_display: item_display_field)
      end

      it { expect(page).not_to have_link }
    end

    context 'when the item is also available at another library' do
      let(:item_display_field) do
        [
          '361051.. -|- HOPKINS -|- STACKS -|- ...',
          '361052.. -|- GREEN -|- STACKS -|- ...'
        ]
      end

      let(:document) do
        SolrDocument.new(item_display: item_display_field)
      end

      it { expect(page).not_to have_link }
    end
  end

  context 'for items with a finding aid' do
    let(:document) do
      SolrDocument.new(
        id: '12345',
        marc_links_struct: [{ href: "http://oac.cdlib.org/ark:/abc123", finding_aid: true }]
      )
    end

    context 'when the item is at a library that prefers finding aids for requests' do
      let(:library) { 'SPEC-COLL' }

      # We send patrons to requests first to show them instructions, but ultimately
      # requests then sends them to the finding aid, which links to Aeon. See:
      # https://github.com/sul-dlss/sul-requests/issues/1333
      it { expect(page).to have_link 'Request via Finding Aid', href: 'https://host.example.com/requests/new?item_id=12345&origin=SPEC-COLL&origin_location=LOCKED-STK' }
    end

    context 'when the item is at a library that does not prefer finding aids for requests' do
      let(:library) { 'GREEN' }

      it { expect(page).to have_link 'Request', href: 'https://host.example.com/requests/new?item_id=12345&origin=GREEN&origin_location=LOCKED-STK' }
    end
  end
end
