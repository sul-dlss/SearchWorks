require "spec_helper"

describe "catalog/_accordion_section_summary.html.erb" do
  include MarcMetadataFixtures
  include ModsFixtures

  describe "Index Summary" do
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
      expect(rendered).to have_css('.accordion-section.summary .snippet', text: /Nunc venenatis et odio ac elementum. Nulla ornare faucibus laoreet/)
      expect(rendered).to have_css('.accordion-section.summary .details', text: summary_text)
    end
  end
  describe "Marc Summary" do
    before do
      view.stub(:document).and_return(
        SolrDocument.new(
          marcxml: metadata2
        )
      )
      render
    end
    it "should include the summary accordion section" do
      expect(rendered).to have_css('.accordion-section.summary')
      expect(rendered).to have_css('.accordion-section.summary a.header', text: "Summary")
    end
    it "should include the toc" do
      expect(rendered).to have_css('ul.toc li', text: '1.First Chapter')
      expect(rendered).to have_css('ul.toc li', text: '2.Second Chapter')
    end
    it "should include the 520 summary" do
      expect(rendered).to have_css('.accordion-section.summary', text: /Selected poems and articles from the works of renowned Sindhi poet/)
    end
  end
  describe "Mods Summary" do
    before do
      view.stub(:document).and_return(
        SolrDocument.new(
          modsxml: mods_everything
        )
      )
      render
    end
    it "should include the summary accordion section" do
      expect(rendered).to have_css('.accordion-section.summary')
      expect(rendered).to have_css('.accordion-section.summary a.header', text: "Summary")
    end
    it "should include the abstract data" do
      expect(rendered).to have_css('.accordion-section.summary', text: /Nunc venenatis et odio ac elementum/)
    end
  end
  describe "no summary" do
    before do
      view.stub(:document).and_return(SolrDocument.new)
      render
    end
    it "should not include any summary accordion section" do
      expect(rendered).to_not have_css('.accordion-section.summary')
    end
  end
end
