# frozen_string_literal: true

require 'spec_helper'

describe AccessPanels::TemporaryAccess do
  let(:document_data) { { ht_bib_key_ssim: ['abc123'], ht_htid_ssim: ['1234567'] } }
  let(:document) { SolrDocument.new(document_data) }
  subject(:temp_access) { described_class.new(document) }

  describe '#present?' do
    context 'when there is hathi data' do
      it { expect(temp_access).to be_present }
    end

    context 'when there is no hathi data' do
      let(:document_data) { {} }

      it { expect(temp_access).not_to be_present }
    end
  end

  describe '#link' do
    context 'when there is a non-publicly available HathiTrust link' do
      it { expect(temp_access.link.html).to match(%r{<a.*>Full text via HathiTrust</a>}) }
    end

    context 'when the HathiTrust link is publicly available' do
      before {  document_data[:ht_access_sim] = ['allow'] }

      it { expect(temp_access.link).not_to be_present }
    end
  end
end
