require "spec_helper"

describe "catalog/_accordion_section_library.html.erb" do

  describe "Accordion section - library" do
    before do
      assign(:document,
        SolrDocument.new(
          id: '123',
          item_display: [
            '123 -|- GREEN -|- STACKS -|- -|- -|- -|- -|- -|- ABC 123'
          ]
        )
      )
      render
    end

    it "should include the library accordion and text" do
      expect(rendered).to have_css('.accordion-section.location')
      expect(rendered).to have_css('.accordion-section.location a.header', text: "At the library")
      expect(rendered).to have_css('.accordion-section.location span.snippet', text: "Green Library")
      expect(rendered).to have_css('.accordion-section .details tbody tr', count: 2)
      expect(rendered).to have_css('.accordion-section .details tbody tr td', text: /Stacks/)
      expect(rendered).to have_css('.accordion-section .details tbody tr td', text: /ABC 123/)
    end
  end

end
