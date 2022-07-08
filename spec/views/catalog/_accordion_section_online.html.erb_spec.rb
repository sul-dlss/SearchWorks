require "spec_helper"

describe "catalog/_index_online_section" do
  include Marc856Fixtures

  describe "Accordion section - Online" do
    context 'regular sirsi record' do
      before do
        expect(view).to receive_messages(
          document: SolrDocument.new(
            id: '12345',
            isbn_display: [123],
            marc_links_struct: [
              { html: 'a', fulltext: true },
              { html: 'b', fulltext: true },
              { html: 'c', fulltext: true },
              { html: 'd', fulltext: true }
            ]
          )
        )
        render
      end

      it 'should include the online dl' do
        expect(rendered).to have_css('dt', text: 'Online')
        expect(rendered).to have_css('dd li', count: 5) # 4 links and a Google Books link
        expect(rendered).to have_css('dd li a', text: 'Google Books (Full view)')
      end
    end

    context 'managed purl record' do
      before do
        expect(view).to receive_messages(
          document: SolrDocument.new(
            id: '12345',
            isbn_display: [123],
            managed_purl_urls: [
              'https://purl.stanford.edu/ct493wg6431',
              'https://purl.stanford.edu/zg338xh5248'
            ]
          )
        )
        render
      end

      it 'does not display Google Books link' do
        expect(rendered).not_to have_css('dd li a', text: 'Google Books (Full view)')
      end
    end
  end
end
