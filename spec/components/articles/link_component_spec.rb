# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Articles::LinkComponent, type: :component do
  subject(:component) { described_class.new(link: link, document: document) }

  let(:document) { EdsDocument.new }

  describe '#links' do
    let(:link) { nil }

    context 'when the document does not have links' do
      it 'is empty' do
        render_inline(component)

        expect(page.native.inner_html).to be_blank
      end
    end

    context 'when the document has a stanford-only link' do
      let(:document) do
        EdsDocument.new({
                          'id' => '00001',
                          'FullText' => {
                            'Links' => [{
                              'Type' => 'pdflink'
                            }]
                          }
                        })
      end

      let(:link) { document.preferred_online_links.first }

      it 'includes the svg popover' do
        render_inline(component)

        expect(page).to have_link 'View/download PDF'
        expect(page).to have_css 'button[aria-label="Stanford-only"] svg'
      end
    end

    context 'when the document does not have a link but does include full-text' do
      let(:document) do
        EdsDocument.new({
                          'id' => 'abc123',
                          'FullText' => {
                            'Text' => {
                              'Availability' => '1',
                              'Value' => '<p>This is the full text of the document.</p>'
                            }
                          }
                        })
      end

      let(:link) { nil }

      it 'includes a link to the document to view the full text' do
        render_inline(component)

        expect(page).to have_link('View on detail page', href: 'http://test.host/articles/abc123')
      end
    end
  end
end
