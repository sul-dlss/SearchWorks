require "spec_helper"

describe Holdings::Status::Pageable do
  describe "pageable libraries" do
    let(:pageable_libraries) { ["SAL3", "SAL-NEWARK"] }

    it "should identify any items in a page-only library as pageable" do
      pageable_libraries.each do |library|
        expect(Holdings::Status::Pageable.new(OpenStruct.new(library: library))).to be_pageable
      end
    end
    it "should identify any items in non page-only libraries as non-pageable" do
      expect(Holdings::Status::Pageable.new(OpenStruct.new(library: "GREEN"))).not_to be_pageable
    end
  end

  describe "pageable locations" do
    it "should identify any location that ends in '-30' as pageable" do
      expect(Holdings::Status::Pageable.new(OpenStruct.new(home_location: "SOMETHING-30"))).to be_pageable
    end
    it "should identify any location w/i the constants list as pageable" do
      Constants::PAGE_LOCS.each do |location|
        expect(Holdings::Status::Pageable.new(OpenStruct.new(home_location: location))).to be_pageable
      end
    end
    it "should identify any non-page location as not pageable" do
      expect(Holdings::Status::Pageable.new(OpenStruct.new(home_location: "SOMETHING"))).not_to be_pageable
    end
  end
end
