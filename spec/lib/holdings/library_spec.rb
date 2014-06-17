require "spec_helper"

describe Holdings::Library do
  it "should translate the library code" do
    expect(Holdings::Library.new("GREEN").name).to eq "Green Library"
  end
  describe "#locations" do
    let(:callnumbers) { [
      Holdings::Callnumber.new("barcode -|- library -|- home-loc -|- "),
      Holdings::Callnumber.new("barcode -|- library -|- home-loc2 -|- "),
      Holdings::Callnumber.new("barcode -|- library -|- home-loc -|- ")
    ] }
    let(:locations) { Holdings::Library.new("GREEN", callnumbers).locations }
    it "should return an array of Holdings::Locations" do
      expect(locations).to be_a Array
      locations.each do |location|
        expect(location).to be_a Holdings::Location
      end
    end
    it "should group by home location" do
      expect(callnumbers.length).to eq 3
      expect(locations.length).to eq 2
      expect(locations.map(&:code)).to eq ["home-loc", "home-loc2"]
    end
  end
  describe "#is_viewable?" do
    it "should be false for PHYSICS" do
      expect(Holdings::Library.new("PHYSICS").is_viewable?).to be_false
    end
    it "should not be false for SUL" do
      expect(Holdings::Library.new("SUL").is_viewable?).to be_false
    end
    it "should not be false for a blank library" do
      expect(Holdings::Library.new("").is_viewable?).to be_false
    end
  end
end
