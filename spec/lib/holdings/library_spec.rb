require "spec_helper"

describe Holdings::Library do
  include Marc856Fixtures
  it "should translate the library code" do
    expect(Holdings::Library.new("GREEN").name).to eq "Green Library"
  end
  describe "#locations" do
    let(:callnumbers) { [
      Holdings::Item.new("barcode -|- library -|- home-loc -|- "),
      Holdings::Item.new("barcode -|- library -|- home-loc2 -|- "),
      Holdings::Item.new("barcode -|- library -|- home-loc -|- ")
    ] }
    let(:sort_callnumbers) { [
      Holdings::Item.new("barcode -|- library -|- TINY -|- "),
      Holdings::Item.new("barcode -|- library -|- STACKS -|- "),
      Holdings::Item.new("barcode -|- library -|- CURRENTPER -|- ")
    ] }
    let(:combined_callnumbers) do
      [
        Holdings::Item.new("barcode1 -|- SPEC-COLL -|- MSS-30 -|- "),
        Holdings::Item.new("barcode2 -|- SPEC-COLL -|- MANUSCRIPT -|- "),
        Holdings::Item.new("barcode3 -|- SPEC-COLL -|- MSS-30 -|- ")
      ]
    end
    let(:locations) { Holdings::Library.new("GREEN", callnumbers).locations }
    let(:sort_locations) { Holdings::Library.new("GREEN", sort_callnumbers).locations }
    let(:combined_locations) { Holdings::Library.new('GREEN', combined_callnumbers).locations }

    it "should return an array of Holdings::Locations" do
      expect(locations).to be_a Array
      locations.each do |location|
        expect(location).to be_a Holdings::Location
      end
    end
    it "should group by home location" do
      expect(callnumbers.length).to eq 3
      expect(locations.length).to eq 2
    end
    it 'groups by home location translation when they are the same' do
      expect(combined_callnumbers.length).to eq 3
      expect(combined_locations.length).to eq 1
    end
    it "should sort by location code when there is no translation" do
      expect(locations.map(&:code)).to eq ["home-loc", "home-loc2"]
    end
    it "should sort locations alpha by name" do
      expect(sort_locations.map(&:name)).to eq ["Current periodicals", "Miniature", "Stacks"]
      expect(sort_locations.map(&:code)).to eq ["CURRENTPER", "TINY", "STACKS"]
    end
  end

  describe "#present?" do
    let(:callnumbers) { [
      Holdings::Item.new(""),
      Holdings::Item.new(""),
      Holdings::Item.new("")
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
        Holdings::Item.new('barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber -|- full_shelfkey -|- public_note -|- callnumber_type'),
        Holdings::Item.new('barcode2 -|- library -|- home_location2 -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber -|- full_shelfkey -|- public_note -|- callnumber_type'),
        Holdings::Item.new('barcode3 -|- library -|- home_location3 -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber -|- full_shelfkey -|- public_note -|- callnumber_type')
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
