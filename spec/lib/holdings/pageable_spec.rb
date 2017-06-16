require "spec_helper"

describe Holdings::Status::Pageable do
  describe "pageable libraries" do
    let(:pageable_libraries) { ["SAL3", "SAL-NEWARK"] }
    it "should identify any items in a page-only library as pageable" do
      pageable_libraries.each do |library|
        expect(described_class.new(instance_double(Holdings::Callnumber, library: library, home_location: ''))).to be_pageable
      end
    end
    it "should identify any items in non page-only libraries as non-pageable" do
      expect(described_class.new(instance_double(Holdings::Callnumber, library: "GREEN", home_location: ''))).to_not be_pageable
    end
  end
  describe "pageable locations" do
    it "should identify any location that ends in '-30' as pageable" do
      expect(described_class.new(instance_double(Holdings::Callnumber, home_location: "SOMETHING-30"))).to be_pageable
    end
    it "should identify any location w/i the constants list as pageable" do
      Constants::PAGE_LOCS.each do |location|
        expect(described_class.new(instance_double(Holdings::Callnumber, home_location: location))).to be_pageable
      end
    end
    it "should identify any non-page location as not pageable" do
      expect(described_class.new(instance_double(Holdings::Callnumber, home_location: "SOMETHING", library: ''))).to_not be_pageable
    end
  end
end
