require 'rails_helper'

RSpec.describe HooverOpenUrlRequest do
  include MarcMetadataFixtures

  subject(:url) { described_class.new(library, document) }

  let(:library) { 'HOOVER' }
  let(:marc_json_struct) { metadata1 }
  let(:document) do
    SolrDocument.new(
      id: 'abc123',
      marc_json_struct:
    )
  end

  before do
    allow(Rails.application.routes).to receive_messages(default_url_options: { host: 'example.com' })
  end

  describe '#to_url' do
    it 'joins the configured base url and the params hash as a query string' do
      expect(url.to_url).to match(/aeon\.dll\?Action=10&Form=20&ItemAuthor=Arbitrary/)
    end
  end

  describe '#to_param' do
    it 'is delegated to the params hash' do
      expect(url.to_param).to match(/&ReferenceNumber=abc123&Value=GenericRequestMonograph/)
    end
  end

  describe 'as_params' do
    it 'is a hash' do
      expect(url.as_params).to be_a Hash
    end

    describe 'hash keys' do
      let(:marc_json_struct) { hoover_request_fixture }

      it 'has keys generic to both libraries' do
        expect(url.as_params.keys).to include 'ItemInfo5'
        expect(url.as_params.keys).to include 'ReferenceNumber'
        expect(url.as_params.keys).to include 'ItemAuthor'
        expect(url.as_params.keys).to include 'Value'
      end

      context 'for HOOVER' do
        it 'includes keys that are specific to hoover' do
          expect(url.as_params.keys).to include 'ItemEdition'
          expect(url.as_params.keys).to include 'ItemPublisher'
        end

        it 'does not include keys that are specific to the archive' do
          expect(url.as_params.keys).not_to include 'ItemInfo3'
          expect(url.as_params.keys).not_to include 'ItemDate'
        end
      end

      context 'for HV-ARCHIVE' do
        let(:library) { 'HV-ARCHIVE' }

        it 'includes keys that are specific to the archive' do
          expect(url.as_params.keys).to include 'ItemInfo3'
          expect(url.as_params.keys).to include 'ItemDate'
        end

        it 'does not include keys that are specific to hoover' do
          expect(url.as_params.keys).not_to include 'ItemEdition'
          expect(url.as_params.keys).not_to include 'ItemPublisher'
        end
      end
    end
  end

  context 'Non library-specific' do
    describe '#record_url' do
      it 'returns the solr document url from the view context' do
        expect(url.record_url).to eq 'https://searchworks.stanford.edu/view/abc123'
      end
    end

    describe '#ckey' do
      it 'returns the document id' do
        expect(url.ckey).to eq document[:id]
      end
    end

    describe '#item_title' do
      it 'returns data from the 245' do
        expect(url.item_title).to eq 'Some intersting papers,'
      end
    end

    describe '#item_author' do
      context 'with multiple authors' do
        it 'returns the first author data' do
          expect(url.item_author).to eq 'Arbitrary, Stewart.'
        end
      end

      context 'with a single author' do
        let(:marc_json_struct) { linked_author_meeting_fixture }

        it 'returns authors later in the metadata when earlier is not present' do
          expect(url.item_author).to eq 'Technical Workshop on Organic Agriculture 2010 : Ogbomoso, Nigeria)'
        end
      end

      context 'with no author' do
        let(:marc_json_struct) { related_works_fixture }

        it 'returns nil' do
          expect(url.item_author).to be_nil
        end
      end
    end

    describe '#item_restrictions' do
      let(:marc_json_struct) { hoover_request_fixture }

      it 'returns 506$3$a' do
        expect(url.item_restrictions).to eq '506 Subfield $3 506 Subfield $a'
      end
    end

    describe '#item_place' do
      it 'returns data from the 300 field' do
        expect(url.item_place).to match(/^53 linear feet/)
      end
    end
  end

  context 'Hoover Library' do
    describe '#request_type' do
      it { expect(url.request_type).to eq 'GenericRequestMonograph' }
    end

    describe '#item_publisher' do
      let(:marc_json_struct) { hoover_request_fixture }

      it 'it returns subfields $a, $b, $c 260/264' do
        expect(url.item_publisher).to eq '260 Subfield $a 260 Subfield $b 260 Subfield $c 264 Subfield $c'
      end
    end

    describe '#item_edition' do
      let(:marc_json_struct) { hoover_request_fixture }

      it 'returns data from the 250$a' do
        expect(url.item_edition).to eq '250 Subfield $a'
      end
    end

    describe '#item_conditions' do
      let(:marc_json_struct) { hoover_request_fixture }

      it { expect(url.item_conditions).to be_nil }
    end
  end

  context 'Hoover Archive' do
    let(:library) { 'HV-ARCHIVE' }

    describe '#request_type' do
      it { expect(url.request_type).to eq 'GenericRequestManuscript' }
    end

    describe '#item_date' do
      let(:marc_json_struct) { hoover_request_fixture }

      it 'returns 245$f' do
        expect(url.item_date).to eq '245 Subfield $f'
      end
    end

    describe '#item_publisher' do
      it { expect(url.item_publisher).to be_nil }
    end

    describe '#item_edition' do
      let(:marc_json_struct) { edition_imprint_fixture }

      it { expect(url.item_edition).to be_nil }
    end

    describe '#item_conditions' do
      let(:marc_json_struct) { hoover_request_fixture }

      it 'returns 540$3$a' do
        expect(url.item_conditions).to eq '540 Subfield $3 540 Subfield $a'
      end
    end
  end
end
