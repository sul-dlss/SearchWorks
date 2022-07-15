require 'spec_helper'

RSpec.describe AccessPanels::OnlineEdsComponent, type: :component do
  let(:document) do
    SolrDocument.new(
      eds_fulltext_links: [{ 'label' => 'HTML full text', 'url' => 'http://example.com', 'type' => 'customlink-fulltext' }]
    )
  end

  before do
    render_inline(described_class.new(document: document))
  end

  it 'renders the panel' do
    expect(page).to have_css('.panel.access-panel.panel-online')
  end

  it 'has the proper heading' do
    expect(page).to have_css('.panel-heading h3', text: 'Best source')
  end

  it 'includes EDS fulltext links' do
    expect(page).to have_css('.panel-body ul li a', text: 'View full text')
  end

  context 'fulltext PDF links (e.g. "detail" href)' do
    let(:document) do
      SolrDocument.new(
        id: 'abc123',
        eds_fulltext_links: [{ 'label' => 'PDF full text', 'url' => 'detail', 'type' => 'pdf' }]
      )
    end

    it 'links to the article_fulltext_link route instead of "detail"' do
      link = page.find('.panel-body li a')
      expect(link['href']).not_to include('detail')
      expect(link['href']).to match(%r{abc123\/pdf\/fulltext})
    end

    it 'the list item has the stanford-only class' do
      list_item = page.find('.panel-body li')
      expect(list_item['class']).to include('stanford-only')
    end
  end

  context 'ILL links' do
    let(:document) do
      SolrDocument.new(
        eds_fulltext_links: [{ 'label' => 'View request options', 'url' => 'http://example.com', 'type' => 'customlink-fulltext' }]
      )
    end

    it 'includes label icon' do
      expect(page).to have_css('.panel-body ul li a.sfx', text: /^Find full text or request/)
    end
  end
end
