require 'rails_helper'

RSpec.describe "catalog/_index_online_section" do
  include Marc856Fixtures

  describe "Accordion section - Online" do
    context 'regular sirsi record' do
      before do
        expect(view).to receive_messages(
          document: SolrDocument.new(
            id: '12345',
            isbn_display: [123],
            marc_links_struct: [
              { href: 'a', fulltext: true },
              { href: 'b', fulltext: true },
              { href: 'c', fulltext: true },
              { href: 'd', fulltext: true }
            ]
          )
        )
        render
      end

      it 'should include the online dl' do
        expect(rendered).to have_css('dt', text: 'Online')
        expect(rendered).to have_css('dd li', count: 4)
        expect(rendered).to have_css('dd li', count: 5, visible: false) # 4 links and a Google Books link
        expect(rendered).to have_css('dd li a', text: 'Google Books (Full view)', visible: false)
      end
    end

    context 'managed purl record' do
      before do
        expect(view).to receive_messages(
          document: SolrDocument.new(
            id: '12345',
            isbn_display: [123],
            marc_links_struct: [
              { href: 'https://purl.stanford.edu/ct493wg6431', managed_purl: true },
              { href: 'https://purl.stanford.edu/zg338xh5248', managed_purl: true }
            ]
          )
        )
        render
      end

      it 'does not display Google Books link' do
        expect(rendered).to have_no_css('dd li a', text: 'Google Books (Full view)')
      end
    end
  end
end
