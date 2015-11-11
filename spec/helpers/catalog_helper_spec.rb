require 'spec_helper'

describe CatalogHelper do
  describe 'current_view' do
    it 'if params[:view] present, should return it' do
      params = { view: 'gallery' }
      helper.stub(:params).and_return(params)
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

    it 'is false when the location ends in -RESV' do
      expect(location_level_request_link?(non_request, reserve_location)).to be false
    end

    it 'is false when the library and location are not location level requests' do
      expect(location_level_request_link?(non_request, non_request)).to be false
    end

    it 'is true when the library is a location level request library' do
      expect(location_level_request_link?(location_level_request, non_request)).to be true
    end

    it 'is true when the location is a location level request location' do
      expect(location_level_request_link?(non_request, location_level_request)).to be true
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
end
