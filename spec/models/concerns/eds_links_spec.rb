require 'rails_helper'

RSpec.describe EdsLinks do
  let(:document) do
    SolrDocument.new(
      'eds_fulltext_links' => [{ 'label' => 'HTML full text', 'url' => 'http://example.com', 'type' => 'customlink-fulltext' }]
    )
  end

  context '#eds_links' do
    it '#all returns an array of Links:link' do
      expect(document.eds_links.all).to be_present

      document.eds_links.all.each do |link|
        expect(link).to be_a Links::Link
      end
    end

    it 'is present when it has a label' do
      expect(document.eds_links.fulltext).to be_present
    end

    it 'does not consider links full-text when label is missing' do
      document['eds_fulltext_links'].first.delete('label')
      expect(document.eds_links.fulltext).not_to be_present
    end

    it 'does not consider links full-text when type is not correct' do
      document['eds_fulltext_links'].first['type'] = 'unknown'
      expect(document.eds_links.fulltext).not_to be_present
    end
  end

  context 'rewriting labels' do
    it 'handles HTML full text' do
      document['eds_fulltext_links'].first['label'] = 'HTML full text'
      expect(document.eds_links.all.first.text).to eq('View full text')
    end

    it 'handles PDF full text variants' do
      document['eds_fulltext_links'].first['label'] = 'PDF full text'
      document['eds_fulltext_links'].first['type'] = 'pdf'
      expect(document.eds_links.all.first.text).to eq('View/download PDF')

      document['eds_fulltext_links'].first['label'] = 'PDF eBook Full Text'
      document['eds_fulltext_links'].first['type'] = 'ebook-pdf'
      expect(document.eds_links.all.first.text).to eq('View/download PDF')
    end

    it 'retains label for ebook-epub links' do
      document['eds_fulltext_links'].first['label'] = 'ePub eBook Full Text'
      document['eds_fulltext_links'].first['type'] = 'ebook-epub'
      expect(document.eds_links.all.first.text).to eq('ePub eBook Full Text')
    end

    it 'handles Check SFX for full text' do
      document['eds_fulltext_links'].first['label'] = 'Check SFX for full text'
      expect(document.eds_links.all.first.text).to eq('View on content provider&#39;s site')
    end

    it 'handles View request options' do
      document['eds_fulltext_links'].first['label'] = 'View request options'
      expect(document.eds_links.all.first.text).to eq('Find full text or request')
    end

    it 'handles Open Access' do
      document['eds_fulltext_links'].first['label'] = 'View in HathiTrust Open Access'
      expect(document.eds_links.all.first.text).to eq('View in HathiTrust Open Access')
    end

    context 'omits unwanted links' do
      it 'skips Access URL' do
        document['eds_fulltext_links'].first['label'] = 'ACCESS URL'
        expect(document.eds_links.fulltext).to be_blank
      end

      it 'skips Availability' do
        document['eds_fulltext_links'].first['label'] = 'AVAILABILITY'
        expect(document.eds_links.fulltext).to be_blank
      end
    end
  end

  context 'stanford only links' do
    it 'sets PDF download links to stanford only' do
      document['eds_fulltext_links'].first['label'] = 'PDF full text'
      expect(document.eds_links.all.first).to be_stanford_only
    end

    it 'sets eBook PDF download links to stanford only' do
      document['eds_fulltext_links'].first['label'] = 'PDF eBook Full Text'
      expect(document.eds_links.all.first).to be_stanford_only
    end

    it 'does not set HTML links to stanford only' do
      document['eds_fulltext_links'].first['label'] = 'HTML full text'
      expect(document.eds_links.all.first).not_to be_stanford_only
    end

    it 'does not set SFX links to stanford only' do
      document['eds_fulltext_links'].first['label'] = 'Check SFX for full text'
      expect(document.eds_links.all.first).not_to be_stanford_only
    end
  end

  context 'non customlink-fulltext links' do
    it 'ignores other link types' do
      document['eds_fulltext_links'].first['type'] = 'unknown'
      expect(document.eds_links.all).not_to be_present
    end
  end

  context 'prioritizing links' do
    let(:all_link_categories) do
      [
        { 'label' => 'HTML FULL TEXT',          'url' => 'http://example.com/1', 'type' => 'customlink-fulltext' },
        { 'label' => 'PDF FULL TEXT',           'url' => 'http://example.com/2', 'type' => 'customlink-fulltext' },
        { 'label' => 'CHECK SFX FOR FULL TEXT', 'url' => 'http://example.com/3', 'type' => 'customlink-fulltext' },
        { 'label' => 'OPEN ACCESS',             'url' => 'http://example.com/4', 'type' => 'customlink-fulltext' },
        { 'label' => 'VIEW REQUEST OPTIONS',    'url' => 'http://example.com/5', 'type' => 'customlink-fulltext' },
        { 'label' => 'ACCESS URL',              'url' => 'http://example.com/6', 'type' => 'customlink-fulltext' } # ignored
      ]
    end

    context 'categories 1 and 2' do
      let(:document) do
        SolrDocument.new('eds_fulltext_links' => all_link_categories)
      end

      it 'shows 1 and 2 only' do
        expect(document.eds_links.fulltext.length).to eq 2
        expect(document.eds_links.fulltext.first.href).to eq('http://example.com/1')
        expect(document.eds_links.fulltext.last.href).to eq('http://example.com/2')
      end
    end

    context 'category 3' do
      let(:document) do
        SolrDocument.new('eds_fulltext_links' => all_link_categories[2..4])
      end

      it 'shows 3 only' do
        expect(document.eds_links.fulltext.length).to eq 1
        expect(document.eds_links.fulltext.first.href).to eq('http://example.com/3')
      end
    end

    context 'category 4' do
      let(:document) do
        SolrDocument.new('eds_fulltext_links' => all_link_categories[3..4])
      end

      it 'shows 4 only' do
        expect(document.eds_links.fulltext.length).to eq 1
        expect(document.eds_links.fulltext.first.href).to eq('http://example.com/4')
      end
    end

    context 'category 5' do
      let(:document) do
        SolrDocument.new('eds_fulltext_links' => [all_link_categories[4]])
      end

      it 'shows 5 only' do
        expect(document.eds_links.fulltext.length).to eq 1
        expect(document.eds_links.fulltext.first.href).to eq('http://example.com/5')
        expect(document.eds_links.fulltext.first.ill?).to be_truthy
      end
    end
  end
end
