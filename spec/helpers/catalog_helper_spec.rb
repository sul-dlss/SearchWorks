require 'spec_helper'

describe CatalogHelper do
  include ModsFixtures
  include MarcMetadataFixtures
  describe '#catalog_search?' do
    context 'when in the CatalogController' do
      before { expect(helper).to receive_messages(controller_name: 'catalog') }

      it { expect(helper.catalog_search?).to be true }
    end

    context 'when not in the CatalogController' do
      before { expect(helper).to receive_messages(controller_name: 'anything_else') }

      it { expect(helper.catalog_search?).to be false }
    end
  end

  describe 'current_view' do
    it 'if params[:view] present, should return it' do
      params = { view: 'gallery' }
      allow(helper).to receive(:params).and_return(params)
      expect(helper.current_view).to eq 'gallery'
    end
    it 'if params is not present, return list' do
      expect(helper.current_view).to eq 'list'
    end
  end

  describe '#location_level_request_link?' do
    let(:non_request) { double(reserve_location?: false, location_level_request?: false) }
    let(:reserve_location) { double(reserve_location?: true) }
    let(:location_level_request) { double(reserve_location?: false, location_level_request?: true) }
    let(:non_requestable_home_loc) { double(reserve_location?: false, code: 'SEE-OTHER') }

    it 'is false when the location ends in -RESV' do
      expect(location_level_request_link?(non_request, reserve_location)).to be_falsy
    end

    it 'is false when the library and location are not location level requests' do
      expect(location_level_request_link?(non_request, non_request)).to be_falsy
    end

    it 'is true when the library is a location level request library' do
      expect(location_level_request_link?(location_level_request, non_request)).to be_truthy
    end

    it 'is true when the location is a location level request location' do
      expect(location_level_request_link?(non_request, location_level_request)).to be_truthy
    end

    it 'is false for requestable libraries if the home location is a non-requestable home location' do
      expect(location_level_request_link?(location_level_request, non_requestable_home_loc)).to be_falsy
    end
  end

  describe 'new_documents_feed_path' do
    it 'returns the search url to an atom feed' do
      expect(new_documents_feed_path).to match %r{^/catalog.atom\?}
    end

    it 'includes the new-to-libs sort key' do
      expect(new_documents_feed_path).to match(/sort=new-to-libs/)
    end

    it 'removes the page parameter' do
      expect(helper).to receive(:params).and_return(page: 5)
      expect(helper.new_documents_feed_path).not_to match(/page=/)
    end
  end

  describe 'link_to_bookplate_search' do
    let(:bookplate) { Bookplate.new('FUND-CODE -|- druid-abc -|- fild-id-123 -|- Bookplate Text') }
    it 'links to the bookplate' do
      expect(link_to_bookplate_search(bookplate)).to include 'f%5Bfund_facet%5D%5B%5D=druid-abc'
    end

    it 'includes the gallery view parameter' do
      expect(link_to_bookplate_search(bookplate)).to include 'view=gallery'
    end

    it 'includes the new to the libraries sort parameter' do
      expect(link_to_bookplate_search(bookplate)).to include 'sort=new-to-libs'
    end

    it 'includes any link options passed in' do
      expect(link_to_bookplate_search(bookplate, class: 'some-class')).to include 'class="some-class"'
    end
  end

  describe '#grouped_citations' do
    it 'sends all the given document citations to the grouped_citations method of the Citation class' do
      documents = [
        double('Document', citations: :abc),
        double('Document', citations: :def)
      ]
      expect(Citation).to receive(:grouped_citations).with([:abc, :def])
      grouped_citations(documents)
    end
  end

  describe '#tech_details' do
    context 'marc document' do
      let(:document) { SolrDocument.new(id: '12345', marcxml: metadata1) }
      it 'adds correct tech details' do
        expect(tech_details(document)).to have_content('Catkey: 12345')
        expect(tech_details(document)).to have_css('a', text: 'Librarian view')
      end
    end
    context 'mods document' do
      let(:document) { SolrDocument.new(id: '12345', modsxml: mods_everything) }
      it 'adds correct tech details' do
        expect(tech_details(document)).to have_content('DRUID: 12345')
        expect(tech_details(document)).to have_css('a', text: 'Librarian view')
      end
    end
    context 'a collection document' do
      let(:document) { SolrDocument.new(id: '12345', modsxml: mods_everything) }
      it 'adds correct tech details' do
        expect(document).to receive(:is_a_collection?).at_least(:once).and_return(true)
        expect(tech_details(document)).to have_content('DRUID: 12345')
        expect(tech_details(document)).to have_css('a', text: 'Librarian view')
        expect(tech_details(document)).to have_css('a', text: 'Collection PURL')
      end
    end
  end

  describe '#iiif_drag_n_drop' do
    it 'creates a IIIF drag n drop link' do
      dnd_link = iiif_drag_n_drop('http://example.io/kittenz/iiif/manifest')
      expect(dnd_link).to match(/data-turbolinks="false" data-toggle="tooltip" data-placement="left"/)
      expect(dnd_link).to match(/title="Drag icon to any IIIF viewer. — Click icon to learn more."/)
      expect(dnd_link).to match(%r{<img width="40" alt="IIIF Drag-n-drop" src="/images/iiif-drag-n-drop.svg" />})
    end
  end
end
