require 'spec_helper'

RSpec.describe 'article/access_panels/_online.html.erb' do
  let(:document) do
    SolrDocument.new(
      eds_fulltext_links: [{ 'label' => 'HTML full text', 'url' => 'http://example.com' }]
    )
  end

  before do
    expect(view).to receive_messages(document: document)
    render
  end

  it 'renders the panel' do
    expect(rendered).to have_css('.panel.access-panel.panel-online')
  end

  it 'has the proper heading' do
    expect(rendered).to have_css('.panel-heading h3', text: 'Available online')
  end

  it 'includes EDS fulltext links' do
    expect(rendered).to have_css('.panel-body ul li a', text: 'View full text')
  end
end
