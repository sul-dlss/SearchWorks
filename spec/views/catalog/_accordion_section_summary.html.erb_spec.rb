require "spec_helper"

describe "catalog/_accordion_section_summary.html.erb" do

  describe "Accordion section - Summary" do
    summary_text = 'Nunc venenatis et odio ac elementum. Nulla ornare faucibus laoreet. Nullam tincidunt a nisi eu pretium'

    before do
      view.stub(:document).and_return(
        SolrDocument.new(
          summary_display: [summary_text]
        )
      )
      render
    end

    it "should include the summary accordion and text" do
      expect(rendered).to have_css('.accordion-section.summary')
      expect(rendered).to have_css('.accordion-section.summary a.header', text: "Summary")
      expect(rendered).to have_css('.accordion-section.summary span.snippet', text: /Nunc venenatis et odio ac elementum. Nulla ornare faucibus laoreet/)
      expect(rendered).to have_css('.accordion-section.summary div.details', text: summary_text)
    end
  end

end
