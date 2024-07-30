# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessPanels::OtherListingsComponent, type: :component do
  include MarcMetadataFixtures

  let(:component) { described_class.new(document:) }

  let(:document_hash) { { id: '123', dor_content_type_ssi: 'notgeo' } }
  let(:document) { SolrDocument.new(document_hash) }

  subject(:page) { render_inline(component) }

  it 'does not render if the item neither is released to Earthworks nor has a PURL' do
    page
    expect(rendered_content).to eq ""
  end

  context 'there is a PURL specified in the MARC' do
    let(:document_hash) do
      {
        id: 'hj948rn6493',
        marc_links_struct: [
          { href: 'https://purl.stanford.edu/hj948rn6493', managed_purl: true }
        ]
      }
    end

    it 'displays a link to the PURL' do
      expect(page).to have_link('Stanford Digital Repository', href: 'https://purl.stanford.edu/hj948rn6493')
    end
  end

  context 'there is a PURL specified in the MODS' do
    let(:document_hash) { { id: 'bd285ct9109', url_fulltext: 'https://purl.stanford.edu/hj948rn6493' } }

    it 'displays a link to the PURL' do
      expect(page).to have_link('Stanford Digital Repository', href: 'https://purl.stanford.edu/hj948rn6493')
    end
  end

  context 'the same PURL is specified in both MARC and MODS' do
    let(:document_hash) do
      {
        id: 'hj948rn6493',
        url_fulltext: 'https://purl.stanford.edu/hj948rn6493',
        marc_links_struct: [
          { href: 'https://purl.stanford.edu/hj948rn6493', managed_purl: true }
        ]
      }
    end

    it 'displays a single link to the PURL' do
      expect(page).to have_link('Stanford Digital Repository', href: 'https://purl.stanford.edu/hj948rn6493')
      expect(page).to have_css('a', count: 1)
    end
  end

  context 'MODS and MARC specify different PURLs' do
    let(:document_hash) do
      {
        id: '123',
        url_fulltext: 'https://purl.stanford.edu/bc123df4567',
        marc_links_struct: [
          { href: 'https://purl.stanford.edu/gh890jk9876', managed_purl: true }
        ]
      }
    end

    it 'displays a single link to the PURL' do
      expect(page).to have_link('https://purl.stanford.edu/bc123df4567', href: 'https://purl.stanford.edu/bc123df4567')
      expect(page).to have_link('https://purl.stanford.edu/gh890jk9876', href: 'https://purl.stanford.edu/gh890jk9876')
      expect(page).to have_css('a', count: 2)
    end
  end

  context 'the object has been released to Earthworks' do
    let(:document_hash) { { id: 'bd285ct9109', druid: 'bd285ct9109', dor_content_type_ssi: 'geo' } }

    it 'displays a link to Earthworks' do
      expect(page).to have_link('Earthworks', href: "https://#{Settings.earthworks.hostname}/catalog/stanford-bd285ct9109")
    end
  end

  context 'the object has been released to Earthworks and it has a PURL' do
    let(:document_hash) { { druid: 'bd285ct9109', url_fulltext: 'https://purl.stanford.edu/bd285ct9109', dor_content_type_ssi: 'geo' } }

    it 'displays a link to the PURL and a link to Earthworks' do
      expect(page).to have_link('Stanford Digital Repository', href: 'https://purl.stanford.edu/bd285ct9109')
      expect(page).to have_link('Earthworks', href: "https://#{Settings.earthworks.hostname}/catalog/stanford-bd285ct9109")
    end
  end
end
