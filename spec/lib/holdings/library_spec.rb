require "spec_helper"

RSpec.describe Holdings::Library do
  include Marc856Fixtures
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
      Holdings::Item.from_item_display_string("barcode -|- library -|- home-loc -|- "),
      Holdings::Item.from_item_display_string("barcode -|- library -|- home-loc2 -|- "),
      Holdings::Item.from_item_display_string("barcode -|- library -|- home-loc -|- ")
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
          Holdings::Item.from_item_display_string("barcode1 -|- SPEC-COLL -|- MSS-30 -|- "),
          Holdings::Item.from_item_display_string("barcode2 -|- SPEC-COLL -|- MANUSCRIPT -|- "),
          Holdings::Item.from_item_display_string("barcode3 -|- SPEC-COLL -|- MSS-30 -|- ")
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
      let(:items) do
        [
          Holdings::Item.from_item_display_string("barcode -|- GREEN -|- SSRC-DOCS -|- "),
          Holdings::Item.from_item_display_string("barcode -|- GREEN -|- STACKS -|- "),
          Holdings::Item.from_item_display_string("barcode -|- GREEN -|- CURRENTPER -|- ")
        ]
      end

      it "sorts locations alpha by name" do
        expect(locations.map(&:name)).to eq ["Current periodicals", "Jonsson Social Sciences Reading Room: Atrium", "Stacks"]
        expect(locations.map(&:code)).to eq ["CURRENTPER", "SSRC-DOCS", "STACKS"]
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
          [Holdings::MHLD.new(" -|-  -|-  -|- no.54(1968:Feb.17),no.56(1968:Mar.2)-no.57(1968:Mar.9),no.63(1968:Apr.20),no.92(1968:Nov.9), no.102(1969:Jan.18),no.107(1969:Feb.22),no.108(1969:Feb.25),no.119(1969:May 24),[1972:Jan-1993:May,1994:Jan-1995:Dec,1998:May-Nov,1999 :Apr-2000:Nov ,2001:Jan-Feb] -|- ")]
        end

        subject { library.locations }

        it { is_expected.to all be_a Holdings::Location }
      end
    end
  end

  describe "#present?" do
    let(:callnumbers) { [
      Holdings::Item.from_item_display_string(""),
      Holdings::Item.from_item_display_string(""),
      Holdings::Item.from_item_display_string("")
    ] }
    let(:library) { Holdings::Library.new("GREEN", callnumbers) }

    it "should be false when libraries have no item display fields" do
      expect(library).not_to be_present
    end
  end

  describe '#library_instructions' do
    it 'should return instructions for libraries which have them' do
      Constants::LIBRARY_INSTRUCTIONS.each_key do |library|
        expect(Holdings::Library.new(library).library_instructions).to have_key(:heading)
        expect(Holdings::Library.new(library).library_instructions).to have_key(:text)
      end
    end
  end

  describe "zombie" do
    let(:zombie) { Holdings::Library.new("ZOMBIE") }

    it "should be #zombie?" do
      expect(zombie).to be_zombie
    end
    it "should not be a holding library" do
      expect(zombie).not_to be_holding_library
    end
  end

  describe '#as_json' do
    let(:callnumbers) do
      [
        Holdings::Item.from_item_display_string('barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber -|- full_shelfkey -|- public_note -|- callnumber_type'),
        Holdings::Item.from_item_display_string('barcode2 -|- library -|- home_location2 -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber -|- full_shelfkey -|- public_note -|- callnumber_type'),
        Holdings::Item.from_item_display_string('barcode3 -|- library -|- home_location3 -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber -|- full_shelfkey -|- public_note -|- callnumber_type')
      ]
    end
    let(:as_json) { Holdings::Library.new('GREEN', callnumbers).as_json }

    it 'should return a hash with all of the libraries public reader methods' do
      expect(as_json).to be_a Hash
      expect(as_json[:code]).to eq 'GREEN'
      expect(as_json[:name]).to eq 'Green Library'
    end
    it 'shuold return an array of locations' do
      expect(as_json[:locations]).to be_a Array
      expect(as_json[:locations].length).to eq 3
      expect(as_json[:locations].first).to be_a Hash
      expect(as_json[:locations].first[:code]).to eq 'home_location'
    end
  end
end
