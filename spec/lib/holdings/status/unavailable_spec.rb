require "spec_helper"

describe Holdings::Status::Unavailable do
  describe "unavailable libraries" do
    let(:status) {
      Holdings::Status::Unavailable.new(
        OpenStruct.new(library: "ZOMBIE")
      )
    }

    it "should be unavailable" do
      expect(status).to be_unavailable
    end
  end

  describe "unavailable home locations" do
    it "should be unavailable" do
      Constants::UNAVAILABLE_LOCS.each do |location|
        expect(Holdings::Status::Unavailable.new(OpenStruct.new(home_location: location))).to be_unavailable
      end
    end
  end

  describe "unavailable current locations" do
    it "is unavailable for all configured locations" do
      Settings.unavailable_current_locations.each do |location|
        expect(Holdings::Status::Unavailable.new(OpenStruct.new(current_location: Holdings::Location.new(location)))).to be_unavailable
      end
    end
    it "should handle identify -LOAN properly as unavailable" do
      expect(Holdings::Status::Unavailable.new(OpenStruct.new(current_location: Holdings::Location.new("SOMETHING-LOAN")))).to be_unavailable
    end
    it "should not identify SPE-LOAN as unavailable" do
      expect(Holdings::Status::Unavailable.new(OpenStruct.new(current_location: Holdings::Location.new("SPE-LOAN")))).not_to be_unavailable
    end
  end
end
