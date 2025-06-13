# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessPanels::SfxComponent do
  let(:document) { SolrDocument.new }

  subject(:access_panel) { described_class.new(document:) }

  describe '#render?' do
    it 'is true when there are links' do
      expect(access_panel).to receive(:sfx_url).and_return(['something'])
      expect(access_panel.render?).to be true
    end

    it 'is fals when there are no links' do
      expect(access_panel).to receive(:sfx_url).and_return(nil)
      expect(access_panel.render?).to be false
    end
  end

  describe '#sfx_url' do
    let(:document) do
      EdsDocument.new(
        'FullText' => {
          'CustomLinks' => [link]
        }
      )
    end

    context 'when an sfx link is present' do
      let(:link) do
        { 'Text' => 'Check SFX for full text', 'Url' => 'http://example.com' }
      end

      it 'returns an eds sfx link' do
        expect(access_panel.sfx_url).to eq 'http://example.com'
      end
    end

    context 'when no sfx links is present' do
      let(:link) do
        { 'Text' => 'HTML full text', 'Url' => 'http://example.com' }
      end

      it 'does not return any links' do
        expect(access_panel.sfx_url).to be_nil
      end
    end
  end
end
