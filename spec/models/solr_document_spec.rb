# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolrDocument do
  include MarcMetadataFixtures
  describe "marc field" do
    let(:marcjson) { SolrDocument.new(marc_json_struct: metadata1) }

    it "responds to #to_marc for marcjson" do
      expect(marcjson).to respond_to(:to_marc)
      expect(marcjson.to_marc).to be_a MARC::Record
    end
  end

  describe "MarcLinks" do
    it "includes marc links" do
      expect(subject).to be_a MarcLinks
    end
  end

  describe "DatabaseDocument" do
    it "includes database document" do
      expect(subject).to be_a DatabaseDocument
    end
  end

  describe "DisplayType" do
    it "includes display type" do
      expect(subject).to be_a DisplayType
      expect(subject).to respond_to(:display_type)
    end
  end

  describe "DigitalCollection" do
    it "includes digital collection" do
      expect(subject).to be_a DigitalCollection
    end
  end

  describe "CollectionMember" do
    it "includes collection member" do
      expect(subject).to be_a CollectionMember
    end
  end

  describe "Extent" do
    it "includes the extent" do
      expect(subject).to be_a Extent
    end
  end

  describe "IndexAuthors" do
    it "includes index authors" do
      expect(subject).to be_a IndexAuthors
    end
  end

  describe "Druid" do
    it "includes druid" do
      expect(subject).to be_a Druid
    end
  end

  describe 'StacksImages' do
    it 'includes the StacksImages mixin' do
      expect(subject).to be_a StacksImages
    end
  end

  describe 'DigitalImage' do
    it 'includes the DigitalImage mixin' do
      expect(subject).to be_a DigitalImage
    end
  end

  describe "SolrHoldings" do
    it "includes SolrHoldings" do
      expect(subject).to be_a SolrHoldings
    end
  end

  describe 'SolrSet' do
    it 'is included' do
      expect(subject).to be_a SolrSet
    end
  end

  describe 'SolrBookplates' do
    it 'is included' do
      expect(subject).to be_a SolrBookplates
    end
  end

  describe 'CitationConcern' do
    it 'is included' do
      expect(subject).to be_a Citable
    end
  end

  describe '#export_as_ris' do
    let(:document) { SolrDocument.new(id: '456') }

    it 'returns computed ris when solr RIS citation is not available' do
      expect(document.export_as_ris).to eq "TY  - GEN\n" \
                                           "DP  - https://searchworks.stanford.edu/view/456\n" \
                                           "UR  - https://searchworks.stanford.edu/view/456\nER  - "
    end
  end

  describe 'MarcBoundWithNote' do
    it 'is included' do
      expect(subject).to be_a MarcBoundWithNote
    end
  end

  describe 'MarcSeries' do
    it 'includes the linked_series method' do
      expect(subject).to respond_to :linked_series
    end

    it 'includes the unlinked_series method' do
      expect(subject).to respond_to :unlinked_series
    end
  end

  describe 'MarcOrganizationAndArrangement' do
    it 'adds the organization_and_arrangement method' do
      expect(subject).to respond_to :organization_and_arrangement
    end
  end

  describe '#id' do
    it 'escapes slashes' do
      expect(SolrDocument.new(id: 'abc/123').id).to eq 'abc%2F123'
    end
  end

  describe '#eresources_library_display_name' do
    let(:eresource_bus_library) { { id: 30, holdings_library_code_ssim: 'BUSINESS', item_display_struct: [] } }

    context 'when it has holdings but no physical items' do
      let(:solr_doc) { SolrDocument.new(eresource_bus_library) }

      it 'is has a eresources_library_display_name' do
        expect(solr_doc.eresources_library_display_name).to eq('Business Library')
      end
    end

    context 'when it is an eresource and has physical copies' do
      let(:item_display) {
        { barcode: 123456, effective_permanent_location_code: 'BUS', library: 'BUSINESS',
          permanent_location_code: 'BUS' }
      }
      let(:physical_location_doc) do
        SolrDocument.new(eresource_bus_library.merge(item_display_struct: [item_display]))
      end

      it 'has an eresource and physical location' do
        expect(physical_location_doc.eresources_library_display_name).to be_nil
      end
    end

    context 'when there are physical items and the library is SUL' do
      solr_info = YAML.load_file(Rails.root.join('spec/fixtures/solr_documents/13553090.yml'))
      let(:solr_doc) { SolrDocument.new(solr_info) }

      it 'does not have a location display' do
        expect(solr_doc.eresources_library_display_name).to be_nil
      end
    end
  end

  describe 'EdsDocument' do
    let(:eds) { EdsDocument.new(eds_title: 'yup') }
    let(:non_eds) { SolrDocument.new }

    it 'eds?' do
      expect(eds.eds?).to be true
      expect(non_eds.eds?).to be false
    end
  end

  describe '#live_lookup_id' do
    let(:document) { SolrDocument.new(id: '11111', uuid_ssi: 'ac0f8371-13ab-55c6-9fcc-1c95bc4fe39f') }

    subject { document.live_lookup_id }

    it { is_expected.to eq 'ac0f8371-13ab-55c6-9fcc-1c95bc4fe39f' }
  end

  describe 'oclc_number' do
    let(:document) { SolrDocument.new(oclc: '12345') }

    subject { document.oclc_number }

    it { is_expected.to eq '12345' }
  end

  describe '#imprint_string' do
    let(:document) { SolrDocument.new(imprint_display: ['a', 'b']) }

    subject { document.imprint_string }

    it { is_expected.to eq 'a' }
  end
end
