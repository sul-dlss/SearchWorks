require 'rails_helper'

RSpec.describe "catalog/_accordion_section_library" do
  describe "Accordion section - library" do
    before do
      assign(:document,
        SolrDocument.new(
          id: '123',
          item_display_struct: [
            { barcode: '123', library: 'GREEN', effective_permanent_location_code: 'GRE-STACKS', callnumber: 'ABC 123' }
          ]
        )
      )
      render
    end

    it "should include the library accordion and text" do
      expect(rendered).to have_css('.accordion-section.location')
      expect(rendered).to have_css('.accordion-section.location button.header[aria-expanded="false"]', text: "Check availability")
      expect(rendered).to have_css('.accordion-section.location span.snippet', text: "Green Library")
      expect(rendered).to have_css('.accordion-section .details[aria-expanded="false"]')
      expect(rendered).to have_css('.accordion-section .details tbody tr', count: 2)
      expect(rendered).to have_css('.accordion-section .details tbody tr th', text: /Stacks/)
      expect(rendered).to have_css('.accordion-section .details tbody tr td', text: /ABC 123/)
    end
  end
end
