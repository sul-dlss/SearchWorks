require "spec_helper"

describe Holdings::Library do
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
    let(:callnumbers) { [
      Holdings::Item.from_item_display_string("barcode -|- library -|- home-loc -|- "),
      Holdings::Item.from_item_display_string("barcode -|- library -|- home-loc2 -|- "),
      Holdings::Item.from_item_display_string("barcode -|- library -|- home-loc -|- ")
    ] }
    let(:sort_callnumbers) { [
      Holdings::Item.from_item_display_string("barcode -|- GREEN -|- SSRC-DOCS -|- "),
      Holdings::Item.from_item_display_string("barcode -|- GREEN -|- STACKS -|- "),
      Holdings::Item.from_item_display_string("barcode -|- GREEN -|- CURRENTPER -|- ")
    ] }
    let(:combined_callnumbers) do
      [
        Holdings::Item.from_item_display_string("barcode1 -|- SPEC-COLL -|- MSS-30 -|- "),
        Holdings::Item.from_item_display_string("barcode2 -|- SPEC-COLL -|- MANUSCRIPT -|- "),
        Holdings::Item.from_item_display_string("barcode3 -|- SPEC-COLL -|- MSS-30 -|- ")
      ]
    end
    let(:locations) { Holdings::Library.new("GREEN", callnumbers).locations }
    let(:sort_locations) { Holdings::Library.new("GREEN", sort_callnumbers).locations }
    let(:combined_locations) { Holdings::Library.new('SPEC-COLL', combined_callnumbers).locations }

    it "returns an array of Holdings::Locations" do
      expect(locations).to be_a Array
      locations.each do |location|
        expect(location).to be_a Holdings::Location
      end
    end

    it "groups by home location" do
      expect(callnumbers.length).to eq 3
      expect(locations.length).to eq 2
    end

    it 'groups by home location translation when they are the same' do
      expect(combined_callnumbers.length).to eq 3
      expect(combined_locations.length).to eq 1
    end

    it "sorts by location code when there is no translation" do
      expect(locations.map(&:code)).to eq ["home-loc", "home-loc2"]
    end

    it "sorts locations alpha by name" do
      expect(sort_locations.map(&:name)).to eq ["Current periodicals", "Jonsson Social Sciences Reading Room: Atrium", "Stacks"]
      expect(sort_locations.map(&:code)).to eq ["CURRENTPER", "SSRC-DOCS", "STACKS"]
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
