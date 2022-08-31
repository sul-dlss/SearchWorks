require "spec_helper"

describe BrowseHelper do
  describe "#link_to_callnumber_browse" do
    let(:document) { SolrDocument.new(id: 'abc123', preferred_barcode: '123') }
    let(:preferred_item) { Holdings::Item.new('123 -|- abc -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- preferred-callnumber') }
    let(:item) { Holdings::Item.new('321 -|- abc -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber') }

    it "should link to the callnumber" do
      expect(link_to_callnumber_browse(document, item)).to have_css('button', text: 'callnumber')
    end
    it "should include correct class" do
      expect(link_to_callnumber_browse(document, item)).to match(/<button*.*class=\"collapsed\"*/)
    end
    it "should include correct data attributes" do
      button = Capybara.string(link_to_callnumber_browse(document, item, 3))
      expect(button).to have_css('button[data-behavior="embed-browse"][data-embed-viewport="#callnumber-3"][data-start="abc123"]')
      # Should add [data-index-path="/browse?start=shelfkey&view=gallery"] to the check,
      # but it's not clear how to create a dummy that would flow through correctly.
    end
  end
end
