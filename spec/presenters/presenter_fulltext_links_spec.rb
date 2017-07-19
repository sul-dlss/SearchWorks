require 'spec_helper'

RSpec.describe PresenterFulltextLinks do
  subject(:presenter) do
    Class.new do
      include PresenterFulltextLinks
    end.new
  end

  let(:view_context) do
    Class.new do
      include ActionView::Helpers::UrlHelper
    end.new
  end

  subject(:result) { Capybara.string(presenter.fulltext_links.join) }

  before do
    config = double(Blacklight::Configuration, index: double(fulltext_links_field: 'eds_fulltext_links'))
    allow(presenter).to receive(:configuration).and_return(config)
    allow(presenter).to receive(:view_context).and_return(view_context)
    allow(presenter).to receive(:document).and_return(document)
  end

  context '#fulltext_links' do
    let(:document) { { 'eds_fulltext_links' => Array.wrap({ 'label' => 'HTML full text', 'url' => 'http://example.com' }) } }

    it 'assumes EDS API returns a hash with label and url'
    it 'renders a list of labeled links' do
      expect(result).to have_css('li.article-fulltext-link', count: 1)
      expect(result).to have_link('View full text', href: 'http://example.com')
    end
    it 'skips using the URL as a label when label is missing' do
      document['eds_fulltext_links'].first.delete('label')
      expect(result).not_to have_link
    end
  end

  context 'rewriting labels' do
    let(:document) { { 'eds_fulltext_links' => Array.wrap('label' => 'My label', 'url' => 'http://example.com') } }

    it 'handles HTML full text' do
      document['eds_fulltext_links'].first['label'] = 'HTML full text'
      expect(result).to have_link('View full text', href: 'http://example.com')
    end

    it 'handles PDF full text' do
      document['eds_fulltext_links'].first['label'] = 'PDF full text'
      expect(result).to have_link('View/download full text PDF', href: 'http://example.com')
    end

    it 'handles Check SFX for full text' do
      document['eds_fulltext_links'].first['label'] = 'Check SFX for full text'
      expect(result).to have_link('View full text on content provider\'s site', href: 'http://example.com')
    end

    it 'handles View request options' do
      document['eds_fulltext_links'].first['label'] = 'View request options'
      expect(result).to have_link('Find it in print or via interlibrary services', href: 'http://example.com')
    end

    it 'errors on some other label' do
      expect(result.native.text).to eq ''
      expect(result).not_to have_link
    end
  end

  context 'prioritizing links' do
    subject(:result) { Capybara.string(presenter.fulltext_links.join) }
    let(:document) { {
      'eds_fulltext_links' => Array.wrap([
        { 'label' => 'HTML FULL TEXT', 'url' => 'http://example.com/1' },
        { 'label' => 'PDF FULL TEXT', 'url' => 'http://example.com/2' },
        { 'label' => 'CHECK SFX FOR FULL TEXT', 'url' => 'http://example.com/3' },
        { 'label' => 'VIEW REQUEST OPTIONS', 'url' => 'http://example.com/4' }
      ] )
    } }

    it 'shows 1 and 2 only' do
      document['eds_fulltext_links'] = document['eds_fulltext_links']
      expect(result).to have_link(href: 'http://example.com/1')
      expect(result).to have_link(href: 'http://example.com/2')
      expect(result).not_to have_link(href: 'http://example.com/3')
      expect(result).not_to have_link(href: 'http://example.com/4')
    end

    it 'shows 3 only' do
      document['eds_fulltext_links'] = document['eds_fulltext_links'].drop(2)
      expect(result).not_to have_link(href: 'http://example.com/1')
      expect(result).not_to have_link(href: 'http://example.com/2')
      expect(result).to have_link(href: 'http://example.com/3')
      expect(result).not_to have_link(href: 'http://example.com/4')
    end

    it 'shows 4 only' do
      document['eds_fulltext_links'] = document['eds_fulltext_links'].drop(3)
      expect(result).not_to have_link(href: 'http://example.com/1')
      expect(result).not_to have_link(href: 'http://example.com/2')
      expect(result).not_to have_link(href: 'http://example.com/3')
      expect(result).to have_link(href: 'http://example.com/4')
    end
  end
end
