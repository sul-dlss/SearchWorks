require "spec_helper"

describe "catalog/_index_location.html.erb" do
  describe "status icon" do
    before do
      view.stub(:document).and_return(
        SolrDocument.new(
          id: '123',
          item_display: [
            '123 -|- SAL3 -|- STACKS -|- -|- -|- -|- -|- -|- ABC 123'
          ]
        )
      )
      render
    end
    it "should include the status icon and text" do
      expect(rendered).to have_css('tbody td i.page')
      expect(rendered).to have_css('tbody td', text: "request")
    end
  end
  describe "single item in a location" do
    before do
      view.stub(:document).and_return(
        SolrDocument.new(
          id: '123',
          item_display: [
            '123 -|- GREEN -|- STACKS -|- -|- -|- -|- -|- -|- ABC 123'
          ]
        )
      )
      render
    end
    it "should display the location and item in a single table row" do
      expect(rendered).to have_css('tbody tr', count: 1)
      expect(rendered).to have_css('tbody tr td', text: /Stacks\s*:\s*ABC 123/)
    end
    it "should not have the indentation class" do
      expect(rendered).to_not have_css('.indent-callnumber')
    end
  end
  describe "multiple items in a location" do
    before do
      view.stub(:document).and_return(
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
      expect(rendered).to have_css('tbody tr td', text: "Stacks")
      expect(rendered).to have_css('tbody tr td', text: "ABC 123")
      expect(rendered).to have_css('tbody tr td', text: "ABC 456")
    end
    it "should add an class for indentation" do
      expect(rendered).to have_css('tbody tr td.indent-callnumber', count: 2)
    end
  end
  describe "request links" do
    describe "location level request links" do
      describe "for a single item" do
        before do
          view.stub(:document).and_return(
            SolrDocument.new(
              id: '123',
              item_display: [
                '123 -|- SAL3 -|- STACKS -|- -|- -|- -|- -|- -|- ABC 123'
              ]
            )
          )
          render
        end
        it "should put the request link with the status icon (since the line is collapsed)" do
          expect(rendered).to have_css('tbody td[data-barcode] a', text: 'Request')
        end
      end
      describe "for multiple items" do
        before do
          view.stub(:document).and_return(
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