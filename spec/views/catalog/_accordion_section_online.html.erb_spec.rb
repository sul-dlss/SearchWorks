require "spec_helper"

describe "catalog/_accordion_section_online.html.erb" do
  include Marc856Fixtures

  describe "Accordion section - Online" do

    before do
      assign(:document,
        SolrDocument.new(
          id: "12345",
          isbn_display: [ 123 ]
        )
      )
      render
    end

    it "should include the online accordion and text" do
      expect(rendered).to have_css('.accordion-section.online')
      expect(rendered).to have_css('.accordion-section.online a.header', text: "Online")
      expect(rendered).to have_css('.details .google-books')
      expect(rendered).to have_css('.details a', text: "Google Books Full view")
    end
  end

end
