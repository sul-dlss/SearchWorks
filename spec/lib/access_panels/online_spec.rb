require 'spec_helper'

describe AccessPanels::Online do
  include ModsFixtures
  include Marc856Fixtures

  let(:fulltext) { described_class.new(SolrDocument.new(marc_links_struct: [{:html=>"<a title='' href='https://library.stanford.edu'>Link text</a> ", :text=>"Link text", :href=>"https://library.stanford.edu", :fulltext=>true, :stanford_only=>nil, :finding_aid=>false, :managed_purl=>nil, :file_id=>nil, :druid=>nil}])) }
  let(:supplemental) { described_class.new(SolrDocument.new) }
  let(:eds_links) do
    described_class.new(
      SolrDocument.new(
        eds_fulltext_links: [{ 'label' => 'HTML full text', 'url' => 'http://example.com', 'type' => 'customlink-fulltext' }]
      )
    )
  end

  let(:sfx) do
    described_class.new(
      SolrDocument.new(url_sfx: 'http://example.com/sfx-link', marcxml: fulltext_856)
    )
  end

  let(:image_collection_member) do
    described_class.new(
      SolrDocument.new(
        collection: ['12345'],
        marc_links_struct: [{:html=>"<a title='' href='https://library.stanford.edu'>Link text</a> ", :text=>"Link text", :href=>"https://library.stanford.edu", :fulltext=>true, :stanford_only=>nil, :finding_aid=>false, :managed_purl=>nil, :file_id=>nil, :druid=>nil}]
      )
    )
  end

  let(:managed_purl_doc) do
    described_class.new(
      SolrDocument.new(
        managed_purl_urls: ['https://library.stanford.edu']
      )
    )
  end

  let(:mods) do
    described_class.new(
      SolrDocument.new(
        collection: ['12345'],
        url_fulltext: 'https://purl.stanford.edu/'
      )
    )
  end

  describe '#present?' do
    it 'is true when there are fulltext links present' do
      expect(fulltext).to be_present
    end

    it 'is true when there are eds links present' do
      expect(eds_links).to be_present
    end

    it 'is false when there are only supplemental links present' do
      expect(supplemental).to_not be_present
    end
  end

  describe '#links' do
    it 'should not return links when they are present in MODS records' do
      expect(mods.links).to_not be_present
    end

    it 'should return fulltext links' do
      expect(fulltext.links.all?(&:fulltext?)).to be_truthy
    end

    it 'should return the SFX link even if there are other links' do
      links = sfx.links
      expect(links.length).to eq 1
      expect(links.first).to be_sfx
      expect(links.first.html).to match %r{^<a href=.*class='sfx'>Find full text<\/a>$}
    end

    it 'returns fulltext links for collection members' do
      expect(image_collection_member.links).to be_present
    end

    it 'does not return managed purls' do
      expect(managed_purl_doc.links).to be_blank
    end

    it 'should not return any non-fulltext links' do
      expect(supplemental.links).to be_blank
    end
  end
end
