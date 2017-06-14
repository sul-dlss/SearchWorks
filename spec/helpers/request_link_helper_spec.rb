require 'spec_helper'

describe RequestLinkHelper do
  let(:current_location_document) do
    SolrDocument.new(
      id: '1234',
      item_display: ['barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber']
    )
  end
  describe 'link_to_request_link' do
    it 'returns link html for the given parameters' do
      link = link_to_request_link(
        document: current_location_document, callnumber: current_location_document.holdings.callnumbers.first
      )
      expect(link).to match(%r{^<a.*/requests/new\?item_id=1234.*</a>$})
    end

    it 'returns nil if the call number is not present' do
      link = link_to_request_link(document: current_location_document, callnumber: nil)
      expect(link).to be_nil
    end

    it 'has the link text "Request" by default' do
      link = link_to_request_link(
        document: current_location_document, callnumber: current_location_document.holdings.callnumbers.first
      )

      expect(Capybara.string(link)).to have_link('Request')
    end

    it 'has the link text "Request on-site access" for on-site libraries' do
      link = link_to_request_link(
        document: current_location_document, library: double(code: 'SPEC-COLL'), callnumber: current_location_document.holdings.callnumbers.first
      )

      expect(Capybara.string(link)).to have_link('Request on-site access')
    end
  end

  describe '#request_link' do
    it 'returns a url passing the appropriate parameters' do
      link = request_link(current_location_document, current_location_document.holdings.callnumbers.first)
      expect(link).to match(%r{^https://host.example.com})
      expect(link).to match(/item_id=1234/)
      expect(link).to match(/origin_location=home_location/)
      expect(link).to match(/origin=library/)
    end

    it 'returns nil when the call number is not present' do
      link = request_link(current_location_document, nil)
      expect(link).to be_nil
    end

    describe 'with barcode' do
      let(:no_current_location_document) do
        SolrDocument.new(
          id: '1234',
          item_display: ['barcode -|- library -|- home_location -|- -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber']
        )
      end
      it 'returns the given barcode in the url' do
        expect(
          request_link(
            no_current_location_document,
            no_current_location_document.holdings.callnumbers.first,
            no_current_location_document.holdings.callnumbers.first.barcode
          )
        ).to match(/barcode=barcode/)
      end
    end

    describe 'SSRC-DATA' do
      let(:ssrc_document) do
        SolrDocument.new(
          id: '1234',
          item_display: ['barcode -|- library -|- SSRC-DATA -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber']
        )
      end
      let(:presenter) do
        OpenStruct.new(heading: 'Document Title')
      end
      before do
        expect(helper).to receive(:show_presenter).with(ssrc_document).and_return(presenter)
      end
      it 'should link to a different form' do
        link = helper.request_link(ssrc_document, ssrc_document.holdings.callnumbers.first)
        expect(link).to match(%r{^http://host.example.com})
        expect(link).to match(/link.ssds_request_form\?/)
        expect(link).to match(/unicorn_id_in=1234/)
        expect(link).to match(/title_in=Document\+Title/)
        expect(link).to match(/call_no_in=callnumber/)
      end
    end
  end
end
