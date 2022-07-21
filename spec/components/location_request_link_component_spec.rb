require 'spec_helper'

RSpec.describe LocationRequestLinkComponent, type: :component do
  include MarcMetadataFixtures

  subject(:component) { described_class.for(document: document, library: library, location: location, items: items) }

  let(:document) { SolrDocument.new(id: '12345') }
  let(:library) { 'GREEN' }
  let(:location) { 'LOCKED-STK' }
  let(:items) { [double(current_location: double(code: nil), circulates?: true)] }

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
    let(:items) { [double(circulates?: false, current_location: double(code: nil))] }

    it { expect(page).not_to have_link }
  end

  context 'when all items are in a mediated page library' do
    let(:library) { 'SPEC-COLL' }
    let(:items) { [double(circulates?: false, current_location: double(code: nil))] }

    it { expect(page).to have_link 'Request on-site access' }
  end

  context 'when all items are in a mediated page location' do
    let(:library) { 'ART' }
    let(:location) { 'ARTLCKL' }
    let(:items) { [double(circulates?: false, current_location: double(code: nil))] }

    it { expect(page).to have_link 'Request' }
  end

  context 'when all items are in a disallowed current location' do
    let(:library) { 'SPEC-COLL' }
    let(:items) { [double(circulates?: true, current_location: double(code: 'SPEC-INPRO'))] }

    it { expect(page).not_to have_link }
  end

  context 'for Hoover Archive items with finding aids' do
    let(:document) do
      SolrDocument.new(
        url_suppl: ['http://oac.cdlib.org/ark:/abc123']
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

    it { expect(page).to have_link 'Request on-site access', href: /hoover.aeon.atlas-sys.com/ }

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
    let(:items) { [double(circulates?: true, current_location: double(code: nil))] }
    let(:item_display_field) do
      [
        '361051.. -|- HOPKINS -|- STACKS -|- ...'
      ]
    end

    it { expect(page).to have_link 'Request' }

    context 'when the item is also available via SFX' do
      let(:document) do
        SolrDocument.new(url_sfx: 'https://library.stanford.edu', item_display: item_display_field)
      end

      it { expect(page).not_to have_link }
    end

    context 'when the full text is also available' do
      let(:document) do
        SolrDocument.new(url_fulltext: 'https://library.stanford.edu', item_display: item_display_field)
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
end
