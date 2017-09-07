require 'spec_helper'

describe AccessPanels::Sfx do
  let(:document) { SolrDocument.new }
  subject(:access_panel) { described_class.new(document) }

  describe '#present?' do
    it 'is true when there are links' do
      expect(access_panel).to receive(:links).and_return(['something'])
      expect(access_panel).to be_present
    end

    it 'is fals when there are no links' do
      expect(access_panel).to receive(:links).and_return([])
      expect(access_panel).not_to be_present
    end
  end

  describe '#links' do
    context 'when an sfx link is present' do
      let(:document) do
        SolrDocument.new(
          'eds_fulltext_links' => [{ 'label' => 'Check SFX for full text', 'url' => 'http://example.com', 'type' => 'customlink-fulltext' }]
        )
      end

      it 'returns an eds sfx link' do
        expect(access_panel.links.length).to eq 1
        expect(access_panel.links.first).to be_a SearchWorks::Links::Link
        expect(access_panel.links.first).to be_sfx
      end
    end

    context 'when no sfx links is present' do
      let(:document) do
        SolrDocument.new(
          'eds_fulltext_links' => [{ 'label' => 'HTML full text', 'url' => 'http://example.com', 'type' => 'customlink-fulltext' }]
        )
      end

      it 'does not return any links' do
        expect(access_panel.links).to eq([])
      end
    end
  end
end
