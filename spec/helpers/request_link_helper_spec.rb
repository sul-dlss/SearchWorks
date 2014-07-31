require "spec_helper"

describe RequestLinkHelper do
  describe "#request_link" do
    let(:current_location_document) {
      SolrDocument.new(
        id: '1234',
        item_display: ['barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber']
      )
    }
    it "should link to the configured requests URL passing the appropriate parameters" do
      link = request_link(current_location_document, current_location_document.holdings.callnumbers.first)
      expect(link).to match /^https:\/\/host\.example\.com/
      expect(link).to match /ckey=1234/
      expect(link).to match /home_loc=home_location/
      expect(link).to match /item_id=barcode/
      expect(link).to match /home_lib=library/
    end
    describe "location level links" do
      let(:sal3_document) {
        SolrDocument.new(
          id: '1234',
          item_display: ['barcode -|- SAL3 -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber']
        )
      }
      it "should not include the barcode" do
        expect(request_link(sal3_document, sal3_document.holdings.callnumbers.first)).to_not match /item_id=/
      end
    end
    describe "no current location" do
      let(:no_current_location_document) {
        SolrDocument.new(
          id: '1234',
          item_display: ['barcode -|- library -|- home_location -|- -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber']
        )
      }
      it "should replace the current location w/ the home location if not present" do
        expect(request_link(no_current_location_document, no_current_location_document.holdings.callnumbers.first)).to match /&current_loc=home_location/
      end
    end
    describe "with current location" do
      it "should link to the current location" do
        expect(request_link(current_location_document, current_location_document.holdings.callnumbers.first)).to match /&current_loc=current_location/
      end
    end
    describe "on order items" do
      let(:on_order_document) {
        SolrDocument.new(
          id: '123',
          item_display: [' -|- -|- ON-ORDER -|- ON-ORDER -|- -|- -|- ']
        )
      }
      let(:link) { request_link(on_order_document, on_order_document.holdings.callnumbers.first) }
      it "should not include an item_id" do
        expect(link).to_not match /item_id=/
      end
      it "should not include an home_lib" do
        expect(link).to_not match /home_lib=/
      end
      it "should include the ckey, current, and home locations" do
        expect(link).to match /ckey=123/
        expect(link).to match /current_loc=ON-ORDER/
        expect(link).to match /home_loc=ON-ORDER/
      end
    end
    describe "SSRC-DATA" do
      let(:ssrc_document) {
        SolrDocument.new(
          id: '1234',
          item_display: ['barcode -|- library -|- SSRC-DATA -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber']
        )
      }
      let(:presenter) {
        OpenStruct.new(document_heading: 'Document Title')
      }
      before do
        expect(helper).to receive(:presenter).with(ssrc_document).and_return(presenter)
      end
      it "should link to a different form" do
        link = helper.request_link(ssrc_document, ssrc_document.holdings.callnumbers.first)
        expect(link).to match /^http:\/\/host\.example\.com/
        expect(link).to match /link.ssds_request_form\?/
        expect(link).to match /unicorn_id_in=1234/
        expect(link).to match /title_in=Document\+Title/
        expect(link).to match /call_no_in=callnumber/
      end
    end
  end
end
