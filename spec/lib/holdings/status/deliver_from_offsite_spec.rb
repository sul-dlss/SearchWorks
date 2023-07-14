require "spec_helper"

RSpec.describe Holdings::Status::DeliverFromOffsite do
  describe "pageable libraries" do
    let(:offsite_libraries) { ["SAL3", "SAL-NEWARK"] }

    it "identifies any items in a page-only library as deliver from offsite" do
      offsite_libraries.each do |library|
        expect(described_class.new(OpenStruct.new(library:))).to be_deliver_from_offsite
      end
    end
    it "identifies any items in non page-only libraries as non-deliverable" do
      expect(described_class.new(OpenStruct.new(library: "GREEN"))).not_to be_deliver_from_offsite
    end
  end

  describe "-30 locations" do
    it "identifies any home location that ends in '-30' as deliverable" do
      expect(described_class.new(OpenStruct.new(home_location: "SOMETHING-30"))).to be_deliver_from_offsite
    end
    it "identifies any location within the constants list as deliverable" do
      Constants::DELIVERABLE_LOCATIONS.each do |location|
        expect(described_class.new(OpenStruct.new(home_location: location))).to be_deliver_from_offsite
      end
    end
    it "identifies any non-page location as not deliverable" do
      expect(described_class.new(OpenStruct.new(home_location: "SOMETHING"))).not_to be_deliver_from_offsite
    end
  end
end
