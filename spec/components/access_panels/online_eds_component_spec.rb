# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessPanels::OnlineEdsComponent, type: :component do
  let(:document) do
    EdsDocument.new({
                      'FullText' => {
                        'CustomLinks' => [
                          { 'Text' => 'HTML full text', 'Url' => 'http://example.com' }
                        ]
                      }
                    })
  end

  before do
    render_inline(described_class.new(document:))
  end

  it 'renders the panel' do
    expect(page).to have_css('.access-panel.panel-online')
  end

  it 'has the proper heading' do
    expect(page).to have_css('.card-header h3', text: 'Best source')
  end

  it 'includes EDS fulltext links' do
    expect(page).to have_css('.card-body ul li a', text: 'View full text')
  end

  context 'fulltext PDF links (e.g. "detail" href)' do
    let(:document) do
      EdsDocument.new(
        'id' => 'abc123',
        'FullText' => {
          'Links' => [
            {
              'Type' => 'pdflink'
            }
          ]
        }
      )
    end

    it 'links to the article_fulltext_link route instead of "detail"' do
      link = page.find('.card-body li a')
      expect(link['href']).not_to include('detail')
      expect(link['href']).to match(%r{abc123\/pdf\/fulltext})
    end

    it 'the list item has the stanford-only class' do
      list_item = page.find('.card-body li button')
      expect(list_item['class']).to include('stanford-only')
    end
  end

  context 'ILL links' do
    let(:document) do
      EdsDocument.new({
                        'FullText' => {
                          'CustomLinks' => [
                            { 'Text' => 'View request options', 'Url' => 'http://example.com' }
                          ]
                        }
                      })
    end

    it 'includes label icon' do
      expect(page).to have_css('.card-body ul li a.sfx', text: /^Find full text or request/)
    end
  end
end
