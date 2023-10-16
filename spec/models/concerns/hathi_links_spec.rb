# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'HathiLinks SolrDocument Concern' do
  let(:document_data) { {} }
  subject(:links) { SolrDocument.new(document_data).hathi_links }

  context 'when there is no Hathi data' do
    it { expect(links).not_to be_present }
  end

  context 'when there is Hathi data' do
    let(:document_data) do
      { ht_bib_key_ssim: ['abc123'], ht_htid_ssim: ['1234567'] }
    end

    it 'is an array of the one HathiTrust link' do
      expect(links).to be_a(Links)
      expect(links.all.length).to eq 1
      expect(links.first.text).to eq 'Full text via HathiTrust'
      expect(links.first).to be_stanford_only
    end
  end

  context 'when the link is publicly available' do
    let(:document_data) do
      { ht_bib_key_ssim: ['abc123'], ht_htid_ssim: ['1234567'], ht_access_sim: ['allow'] }
    end

    it 'is not stanford only' do
      expect(links.all.length).to eq 1
      expect(links.first.text).to eq 'Full text via HathiTrust'
      expect(links.first).not_to be_stanford_only
    end
  end
end
