require 'spec_helper'

RSpec.describe EdsLinks do
  context '#eds_links' do
    let(:document) do
      SolrDocument.new(
        'eds_fulltext_links' => [{ 'label' => 'HTML full text', 'url' => 'http://example.com' }]
      )
    end

    it '#all returns an array of SearchWorks::Links:link' do
      expect(document.eds_links.all).to be_present

      document.eds_links.all.each do |link|
        expect(link).to be_a SearchWorks::Links::Link
      end
    end

    it 'does not consider a links a full-text when label is missing' do
      expect(document.eds_links.fulltext).to be_present

      document['eds_fulltext_links'].first.delete('label')
      expect(document.eds_links.fulltext).not_to be_present
    end
  end

  context 'rewriting labels' do
    let(:document) do
      SolrDocument.new(
        'eds_fulltext_links' => [{ 'label' => 'My label', 'url' => 'http://example.com' }]
      )
    end

    it 'handles HTML full text' do
      document['eds_fulltext_links'].first['label'] = 'HTML full text'

      expect(document.eds_links.all.first.text).to eq('View full text')
    end

    it 'handles PDF full text' do
      document['eds_fulltext_links'].first['label'] = 'PDF full text'

      expect(document.eds_links.all.first.text).to eq('View/download full text PDF')
    end

    it 'handles Check SFX for full text' do
      document['eds_fulltext_links'].first['label'] = 'Check SFX for full text'

      expect(document.eds_links.all.first.text).to eq('View full text on content provider\'s site')
    end

    it 'handles View request options' do
      document['eds_fulltext_links'].first['label'] = 'View request options'

      expect(document.eds_links.all.first.text).to eq('Find it in print or via interlibrary services')
    end

    it 'errors on some other label' do
      expect(document.eds_links.fulltext).to be_blank
    end
  end

  context 'prioritizing links' do
    let(:document) do
      SolrDocument.new(
        'eds_fulltext_links' => [
          { 'label' => 'HTML FULL TEXT', 'url' => 'http://example.com/1' },
          { 'label' => 'PDF FULL TEXT', 'url' => 'http://example.com/2' },
          { 'label' => 'CHECK SFX FOR FULL TEXT', 'url' => 'http://example.com/3' },
          { 'label' => 'VIEW REQUEST OPTIONS', 'url' => 'http://example.com/4' }
        ]
      )
    end

    it 'shows 1 and 2 only' do
      document['eds_fulltext_links'] = document['eds_fulltext_links']

      expect(document.eds_links.fulltext.length).to eq 2
      expect(document.eds_links.fulltext.first.href).to eq('http://example.com/1')
      expect(document.eds_links.fulltext.last.href).to eq('http://example.com/2')
    end

    it 'shows 3 only' do
      document['eds_fulltext_links'] = document['eds_fulltext_links'].drop(2)

      expect(document.eds_links.fulltext.length).to eq 1
      expect(document.eds_links.fulltext.first.href).to eq('http://example.com/3')
    end

    it 'shows 4 only' do
      document['eds_fulltext_links'] = document['eds_fulltext_links'].drop(3)

      expect(document.eds_links.fulltext.length).to eq 1
      expect(document.eds_links.fulltext.first.href).to eq('http://example.com/4')
    end
  end
end
