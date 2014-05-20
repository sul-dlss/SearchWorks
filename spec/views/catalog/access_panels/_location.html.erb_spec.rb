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
end
