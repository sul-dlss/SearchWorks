require "spec_helper"

describe "catalog/_index_location.html.erb" do
  describe "status icon" do
    before do
      view.stub(:document).and_return(
        SolrDocument.new(
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
end