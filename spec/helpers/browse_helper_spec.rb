require "spec_helper"

describe BrowseHelper do
  describe "#link_to_callnumber_browse" do
    let(:document) { SolrDocument.new(id: 'abc123', preferred_barcode: '123') }
    let(:preferred_callnumber) { Holdings::Callnumber.new('123 -|- abc -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- preferred-callnumber') }
    let(:callnumber) { Holdings::Callnumber.new('321 -|- abc -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber') }
    it "should link to the callnumber" do
      expect(link_to_callnumber_browse(document, callnumber)).to have_css('a', text: 'callnumber')
    end
    it "should link to the gallery view by default" do
      expect(link_to_callnumber_browse(document, callnumber)).to match(/<a*.*href=\".*view=gallery.*\"/)
    end
    it "should include the barcode if the callnumber does not have the document's preferred barcode" do
      expect(link_to_callnumber_browse(document, callnumber)).to match(/<a*.*href=\".*barcode=321.*\"/)
    end
    it "should not include the barcode if the callnumber's barcode is the same as the document's preferred barcode" do
      expect(link_to_callnumber_browse(document, preferred_callnumber)).to_not match(/<a*.*href=\".*barcode.*\">/)
    end
    it "should include correct class" do
      expect(link_to_callnumber_browse(document, callnumber)).to match(/<a*.*class=\"collapsed\"*/)
    end
    it "should include correct data attributes" do
      link = Capybara.string(link_to_callnumber_browse(document, callnumber, 3))
      expect(link).to have_css('a[data-behavior="embed-browse"][data-embed-viewport="#callnumber-3"][data-start="abc123"]')
    end
  end
end
