# frozen_string_literal: true

require 'spec_helper'

describe HathiTrustLinks do
  let(:document_data) { { ht_bib_key_ssim: ['abc123'], ht_htid_ssim: ['1234567'] } }
  let(:document) { SolrDocument.new(document_data) }
  subject(:ht_links) { described_class.new(document) }

  describe '#present?' do
    context 'when there is hathi data' do
      it { expect(ht_links).to be_present }
    end

    context 'when there is no hathi data' do
      let(:document_data) { {} }

      it { expect(ht_links).not_to be_present }
    end

    context 'when the document has fulltext' do
      before { document_data[:url_fulltext] = ['http://example.com'] }

      it { expect(ht_links).not_to be_present }
    end
  end

  describe '#publicly_available?' do
    context 'when there is no access data' do
      it { expect(ht_links).not_to be_publicly_available }
    end

    context 'when the access statements include deny' do
      before { document_data[:ht_access_sim] = ['deny', 'allow'] }

      it { expect(ht_links).not_to be_publicly_available }
    end

    context 'when the access statements include allow (but have copyright status that does not guarantee access)' do
      before { document_data[:ht_access_sim] = ['allow', 'allow:icus'] }

      it { expect(ht_links).not_to be_publicly_available }
    end

    context 'when the access statments indicate users can access' do
      before { document_data[:ht_access_sim] = ['allow', 'allow:pd'] }

      it { expect(ht_links).to be_publicly_available }
    end
  end

  describe '#url' do
    context 'when there is no item ID' do
      before do
        document_data[:ht_htid_ssim] = nil
      end

      it 'is the url to the work' do
        expect(ht_links.url).to include('hathitrust.org/Record/abc123')
      end
    end

    context 'when the document has many holdings' do
      before do
        document_data[:item_display] = [
          '123 -|- GREEN -|- STACKS -|-  -|-  -|-  -|-  -|-  -|- AB 123 -|- ',
          '321 -|- GREEN -|- STACKS -|-  -|-  -|-  -|-  -|-  -|- AB 321 -|- '
        ]
      end

      it 'is the url to the work' do
        expect(ht_links.url).to include('hathitrust.org/Record/abc123')
      end
    end

    context 'when the document only has one holding' do
      before do
        document_data[:item_display] = [
          '123 -|- GREEN -|- STACKS -|-  -|-  -|-  -|-  -|-  -|- AB 123 -|- '
        ]
      end

      it 'is the url to the item' do
        expect(ht_links.url).to include('hathitrust.org/cgi/pt?id=1234567&view=1up')
      end
    end
  end

end
