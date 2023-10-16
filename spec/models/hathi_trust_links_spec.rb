# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HathiTrustLinks do
  subject(:ht_links) { described_class.new(document) }

  let(:document_data) { { ht_bib_key_ssim: ['abc123'], ht_htid_ssim: ['1234567'] } }
  let(:document) { SolrDocument.new(document_data) }

  describe '#present?' do
    context 'when there is hathi data' do
      it { expect(ht_links).to be_present }
    end

    context 'when there is no hathi data' do
      let(:document_data) { {} }

      it { expect(ht_links).not_to be_present }
    end

    context 'when the document has fulltext' do
      before do
        document_data[:marc_links_struct] = [{
          href: "https://example.com",
          link_text: "The Link",
          fulltext: true,
          stanford_only: true
        }]
      end

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
        expect(ht_links.url).to include('?signon=swle:urn:mace')
      end

      context 'when publicly_available' do
        it 'includes the signon param' do
          expect(ht_links.url).to include('?signon=swle:urn:mace')
        end
      end

      context 'when not publicly_available' do
        before { document_data[:ht_access_sim] = ['deny'] }

        it 'includes the signon param' do
          expect(ht_links.url).to include('hathitrust.org/Record/abc123?signon=swle:urn:mace:incommon:stanford.edu')
        end
      end
    end

    context 'when the document has many holdings' do
      before do
        document_data[:item_display_struct] = [
          { barcode: '123', library: 'GREEN', location: 'STACKS', callnumber: 'AB 123' },
          { barcode: '321', library: 'GREEN', location: 'STACKS', callnumber: 'AB 321' }
        ]
      end

      it 'is the url to the work' do
        expect(ht_links.url).to include('hathitrust.org/Record/abc123')
      end
    end

    context 'when the document only has one holding' do
      before do
        document_data[:item_display_struct] = [
          { barcode: '123', library: 'GREEN', location: 'STACKS', callnumber: 'AB 123' }
        ]
      end

      it 'is the url to the item' do
        expect(ht_links.url).to include('hathitrust.org/cgi/pt?id=1234567')
      end

      context 'when publicly_available' do
        it 'passes the item URL through the target param' do
          expect(ht_links.url).to include('target=https://babel.hathitrust.org/cgi/pt?id=1234567')
        end
      end

      context 'when not publicly_available' do
        before do
          document_data[:ht_access_sim] = ['deny']
          document_data[:ht_htid_ssim] = ['loc.ark:/13960/t17m0qv0b']
        end

        it 'bounces the user to shibboleth with the encoded item URL in the target param' do
          expect(ht_links.url).to include('babel.hathitrust.org/Shibboleth.sso/Login?entityID=urn:mace:incommon:stanford.edu&target=https://babel.hathitrust.org/cgi/pt?id=loc.ark%3A%2F13960%2Ft17m0qv0b')
        end
      end
    end
  end
end
