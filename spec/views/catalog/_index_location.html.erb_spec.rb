require "spec_helper"

describe "catalog/_index_location.html.erb" do
  describe "accessibility" do
    before do
      allow(view).to receive(:document).and_return(
        SolrDocument.new(
          id: '123',
          item_display: [
            '123 -|- GREEN -|- STACKS -|- -|- -|- -|- -|- -|- ABC 123'
          ]
        )
      )
      render
    end
    it "should have a caption" do
      expect(rendered).to have_css('caption.sr-only', text: 'Status of items at Green Library')
    end
    describe "column scope" do
      it "should be on the library name" do
        expect(rendered).to have_css('th[scope="col"]', text: 'Green Library')
      end
      it "should be on the status column" do
        expect(rendered).to have_css('th[scope="col"]', text: 'Status')
      end
      it "should be on the location name" do
        expect(rendered).to have_css('th[scope="col"]', text: 'Stacks')
      end
    end
  end
  describe 'location level requests' do
    before do
      allow(view).to receive(:document).and_return(
        SolrDocument.new(
          id: '123',
          item_display: [
            '123 -|- GREEN -|- UARCH-30 -|- -|- -|- -|- -|- -|- ABC 123'
          ]
        )
      )
      render
    end
    it 'should have the request link at the location level' do
      expect(rendered).to have_css('tbody th strong', text: "University Archives")
      expect(rendered).to have_css('tbody td a', text: "Request")
    end
  end
  describe "status icon" do
    before do
      allow(view).to receive(:document).and_return(
        SolrDocument.new(
          id: '123',
          item_display: [
            '123 -|- SAL3 -|- STACKS -|- -|- -|- -|- -|- -|- ABC 123'
          ]
        )
      )
      render
    end
    it "should include the status icon" do
      expect(rendered).to have_css('tbody td i.page')
    end
  end
  describe "status text" do
    before do
      allow(view).to receive(:document).and_return(
        SolrDocument.new(
          id: '123',
          item_display: [
            '123 -|- GREEN -|- STACKS -|- -|- -|- -|- -|- -|- ABC 123',
            '321 -|- SPEC-COLL -|- STACKS -|- -|- -|- -|- -|- -|- ABC 321'
          ]
        )
      )
      render
    end
    it "should have unknown status text for items we'll be looking up" do
      expect(rendered).to have_css('.status-text', text: 'Unknown')
    end
    it "should have explicit status text for items that we know the status" do
      expect(rendered).to have_css('.status-text', text: 'In-library use')
    end
  end
  describe "multiple items in a location" do
    before do
      allow(view).to receive(:document).and_return(
        SolrDocument.new(
          id: '123',
          item_display: [
            '123 -|- GREEN -|- STACKS -|- -|- -|- -|- -|- -|- ABC 123',
            '456 -|- GREEN -|- STACKS -|- -|- -|- -|- -|- -|- ABC 456'
          ]
        )
      )
      render
    end
    it "should display the location and items in separate table rows" do
      expect(rendered).to have_css('tbody tr', count: 3)
      expect(rendered).to have_css('tbody tr th', text: "Stacks")
      expect(rendered).to have_css('tbody tr td', text: "ABC 123")
      expect(rendered).to have_css('tbody tr td', text: "ABC 456")
    end
    it "should add an class for indentation" do
      expect(rendered).to have_css('tbody tr td.indent-callnumber', count: 2)
    end
  end
  describe "bound with" do
    before do
      allow(view).to receive(:document).and_return(
        SolrDocument.new(
          id: '123',
          item_display: ['1234 -|- SAL3 -|- SEE-OTHER -|- -|- -|- -|- -|- -|- ABC 123']
        )
      )
      render
    end
    it "should not display request links for requestable libraries" do
      expect(rendered).to_not have_content("Request")
    end
  end
  describe "mhld" do
    describe "with matching library/location" do
      before do
        allow(view).to receive(:document).and_return(SolrDocument.new(
          id: '123',
          item_display: ['321 -|- GREEN -|- STACKS -|- -|- -|- -|- -|- -|- ABC 123'],
          mhld_display: ['GREEN -|- STACKS -|- public note -|- library has -|- latest received']
        ))
        render
      end
      it "should include the matched MHLD" do
        expect(rendered).to have_css('tbody tr', count: 2)
        expect(rendered).to have_css('tbody tr th', text: /Stacks.*public note/m)
        expect(rendered).to have_css('tbody tr td', text: "ABC 123")
        expect(rendered).to have_css('tbody tr td', text: "Latest: latest received")
      end
    end
    describe "that has no matching library/location" do
      before do
        allow(view).to receive(:document).and_return(SolrDocument.new(
          id: '123',
          mhld_display: ['GREEN -|- STACKS -|- public note -|- library has -|- latest received']
        ))
        render
      end
      it "should invoke a library block w/ the appropriate mhld data" do
        expect(rendered).to have_css('tbody tr', count: 1)
        expect(rendered).to have_css('tbody tr th', text: /Stacks.*public note/m)
        expect(rendered).to have_css('tbody tr td', text: "Latest: latest received")
      end
    end
    describe "with mhld that only has 'Library has' statement" do
      before do
        allow(view).to receive(:document).and_return(SolrDocument.new(
          id: '123',
          item_display: ['123 -|- GREEN -|- STACKS -|- -|- -|- -|- -|- -|- ABC 123'],
          mhld_display: ['GREEN -|- CURRENTPER -|- -|- library has -|-']
        ))
        render
      end
      it "should not display the location" do
        expect(rendered).to have_css('tbody tr', count: 2)
        expect(rendered).to_not have_content('library has')
        expect(rendered).to_not have_content('Current Periodicals')
      end
    end
  end
  describe "request links" do
    describe "location level request links" do
      describe "for multiple items" do
        before do
          allow(view).to receive(:document).and_return(
            SolrDocument.new(
              id: '123',
              item_display: [
                '123 -|- SAL3 -|- STACKS -|- -|- -|- -|- -|- -|- ABC 123',
                '456 -|- SAL3 -|- STACKS -|- -|- -|- -|- -|- -|- ABC 456'
              ]
            )
          )
          render
        end
        it "should put the request in the row w/ the location (since there will be multiple rows for callnumbers)" do
          expect(rendered).to have_css('tbody td a', text: 'Request')
          expect(rendered).to_not have_css('tbody td[data-barcode] a', text: 'Request')
        end
      end
    end
  end
end
