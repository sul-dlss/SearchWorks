# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Holdings::Library do
  describe '#name' do
    it "translates the library code" do
      expect(Holdings::Library.new("GREEN").name).to eq "Green Library"
    end

    context 'with a FOLIO item' do
      let(:items) { [instance_double(Holdings::Item, folio_item?: true, permanent_location: double(library:), effective_location: nil)] }
      let(:library) { Folio::Library.new(id: 'green', code: 'GREEN', name: 'Cecil R. Green Library') }

      it "translates the library code using the FOLIO library data" do
        expect(Holdings::Library.new("GREEN", items).name).to eq "Cecil R. Green Library"
      end
    end

    context 'with a FOLIO item in a temporary location we treat at the permanent location for display' do
      let(:items) { [instance_double(Holdings::Item, folio_item?: true, permanent_location: double(sal3:), effective_location:)] }
      let(:effective_location) { instance_double(Folio::Location, details: { 'searchworksTreatTemporaryLocationAsPermanentLocation' => true }, library:) }
      let(:library) { Folio::Library.new(id: 'green', code: 'GREEN', name: 'Cecil R. Green Library') }
      let(:sal3) { Folio::Library.new(id: 'sal3', code: 'SAL3', name: 'SAL3') }

      it "translates the library code using the FOLIO library data" do
        expect(Holdings::Library.new("GREEN", items).name).to eq "Cecil R. Green Library"
      end
    end
  end

  describe "#locations" do
    let(:items) { [
      Holdings::Item.new({ barcode: 'barcode', library: 'library', effective_permanent_location_code: 'home-loc' }),
      Holdings::Item.new({ barcode: 'barcode', library: 'library', effective_permanent_location_code: 'home-loc2' }),
      Holdings::Item.new({ barcode: 'barcode', library: 'library', effective_permanent_location_code: 'home-loc' })
    ] }

    let(:locations) { Holdings::Library.new("GREEN", items).locations }

    it "returns an array of Holdings::Locations" do
      expect(locations).to all be_a Holdings::Location
    end

    it "groups by home location" do
      expect(locations.length).to eq 2
    end

    context 'when several locations have the same translation' do
      let(:locations) { Holdings::Library.new('SPEC-COLL', items).locations }

      let(:items) do
        [
          Holdings::Item.new({ barcode: 'barcode1', library: 'SPEC-COLL', effective_permanent_location_code: 'SPEC-MSS-10' }),
          Holdings::Item.new({ barcode: 'barcode2', library: 'SPEC-COLL', effective_permanent_location_code: 'SPEC-MANUSCRIPT' }),
          Holdings::Item.new({ barcode: 'barcode3', library: 'SPEC-COLL', effective_permanent_location_code: 'SPEC-MSS-10' })
        ]
      end

      it 'groups them together' do
        expect(locations.length).to eq 1
      end
    end

    it "sorts by location code when there is no translation" do
      expect(locations.map(&:code)).to eq ["home-loc", "home-loc2"]
    end

    describe 'sorting' do
      let(:locations) { Holdings::Library.new("GREEN", items).locations }
      let(:items) { [
        Holdings::Item.new({ barcode: 'barcode', library: 'GREEN', effective_permanent_location_code: 'GRE-SSRC-DOCS', discoveryDisplayName: 'Current periodicals' }),
        Holdings::Item.new({ barcode: 'barcode', library: 'GREEN', effective_permanent_location_code: 'SAL-PAGE' }),
        Holdings::Item.new({ barcode: 'barcode', library: 'GREEN', effective_permanent_location_code: 'GRE-CURRENTPER' })
      ] }

      it "sorts locations alpha by name" do
        expect(locations.map(&:name)).to eq ["Current periodicals", "Jonsson Social Sciences Reading Room: Atrium", "SAL"]
        expect(locations.map(&:code)).to eq ["GRE-CURRENTPER", "GRE-SSRC-DOCS", "SAL-PAGE"]
      end

      context 'when a zombie location has mhlds with nil location (hrid: a356446)' do
        let(:library) do
          described_class.new('ZOMBIE', items, mhlds)
        end
        let(:items) do
          [
            Holdings::Item.new({})
          ]
        end
        let(:mhlds) do
          [Holdings::MHLD.new(" -|-  -|-  -|- no.54(1968:Feb.17),no.56(1968:Mar.2)-no.57(1968:Mar.9) ... -|- ")]
        end

        subject { library.locations }

        it { is_expected.to all be_a Holdings::Location }
      end
    end
  end

  describe "#present?" do
    let(:callnumbers) { [
      Holdings::Item.new({}),
      Holdings::Item.new({}),
      Holdings::Item.new({})
    ] }
    let(:library) { Holdings::Library.new("GREEN", callnumbers) }

    it "is false when libraries have no item display fields" do
      expect(library).not_to be_present
    end
  end

  describe '#library_instructions' do
    it 'returns instructions for libraries which have them' do
      Constants::LIBRARY_INSTRUCTIONS.each_key do |library|
        expect(Holdings::Library.new(library).library_instructions).to have_key(:text)
      end
    end
  end

  describe "zombie" do
    let(:zombie) { Holdings::Library.new("ZOMBIE") }

    it "is #zombie?" do
      expect(zombie).to be_zombie
    end
    it "is not a holding library" do
      expect(zombie).not_to be_holding_library
    end
  end
end
