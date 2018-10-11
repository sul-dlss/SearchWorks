require "spec_helper"

describe "catalog/_accordion_section_online.html.erb" do
  include Marc856Fixtures

  describe "Accordion section - Online" do
    context 'regular sirsi record' do
      before do
        assign(:document,
          SolrDocument.new(
            id: "12345",
            isbn_display: [ 123 ],
            marcbib_xml: stanford_only_856
          )
        )
        render
      end

      it "should include the online accordion and text" do
        expect(rendered).to have_css('.accordion-section.online')
        expect(rendered).to have_css('.accordion-section.online button.header[aria-expanded="false"]', text: "Online")
        expect(rendered).to have_css('.details[aria-expanded="false"] .google-books')
        expect(rendered).to have_css('.details a', text: "Google Books (Full view)")
      end
      it 'should include the first link in the snippet' do
        expect(rendered).to have_css('.snippet span.stanford-only a', text: 'Link text', count: 1)
      end
      it "should include the links" do
        expect(rendered).to have_css('ul.links span.stanford-only a', text: 'Link text', count: 4)
      end
    end
    context 'managed purl record' do
      before do
        assign(
          :document,
          SolrDocument.new(
            id: '12345',
            isbn_display: [123],
            marcbib_xml: many_managed_purl_856,
            managed_purl_urls: [
              'https://purl.stanford.edu/ct493wg6431',
              'https://purl.stanford.edu/zg338xh5248'
            ]
          )
        )
        render
      end
      it 'does not display Google Books link' do
        expect(rendered).not_to have_css '.details a', text: 'Google Books (Full view)'
      end
    end
  end

end
