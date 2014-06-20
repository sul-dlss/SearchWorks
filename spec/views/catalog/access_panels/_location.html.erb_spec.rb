require "spec_helper"

describe "catalog/access_panels/_location.html.erb", js:true do
  describe "non location record" do
    before do
      assign(:document, SolrDocument.new)
    end
    it "should not render any panel" do
      render
      expect(rendered).to be_blank
    end
  end
  describe "object with a location" do
    it "should render the panel" do
      assign(:document, SolrDocument.new(id: '123', item_display: ["36105217238315 -|- EARTH-SCI -|- STACKS -|-  -|- STKS -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011 -|- en~j~~~zzsz}xyxzzz~pz}vxtzzz~zzxzyy~~~~~~~~~~~~~~~ -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011"]))
      render
      expect(rendered).to have_css(".panel-library-location")
      expect(rendered).to have_css(".library-location-heading")
      expect(rendered).to have_css(".library-location-heading-text a", text: "Earth Sciences Library (Branner)")
      expect(rendered).to have_css("div.location-hours-today")
      expect(rendered).to have_css(".panel-body")
    end
  end
  describe "current locations" do
    it "should be displayed" do
      assign(:document, SolrDocument.new(
        item_display: ['123 -|- GREEN -|- STACKS -|- INPROCESS -|- -|- -|- -|- -|- ABC 123']
      ))
      render
      expect(rendered).to have_css('.current-location', text: 'In process')
    end
    describe "as home location" do
      before do
        assign(:document, SolrDocument.new(
          item_display: ['123 -|- ART -|- STACKS -|- IC-DISPLAY -|- -|- -|- -|- -|- ABC 123']
        ))
        render
      end
      it "should display the current location as the home location" do
        expect(rendered).to_not have_css('.location-name', text: "Stacks")
        expect(rendered).to have_css('.location-name', text: "InfoCenter: display")
      end
      it "should not be displayed if the current location is a special location that gets treated like a home location" do
        expect(rendered).to_not have_css('.current-location')
      end
    end
    describe "is reserve desk" do
      it "should use the library of the owning reserve desk" do
        assign(:document, SolrDocument.new(
          item_display: ['123 -|- ART -|- STACKS -|- GREEN-RESV -|- -|- -|- -|- -|- ABC 123']
        ))
        render
        expect(rendered).to have_css('.library-location-heading-text a', text: 'Green Library')
      end
    end
  end
end
