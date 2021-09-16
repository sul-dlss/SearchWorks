require "spec_helper"

describe Holdings::Status::Noncirc do
  describe "Business rules" do
    let(:other_microfilm) { OpenStruct.new(library: 'SOMETHING-ELSE', home_location: 'MICROFILM') }
    let(:business_microfilm) { OpenStruct.new(library: 'BUSINESS', home_location: 'MICROFILM') }

    it "should have custom noncirc locations" do
      expect(Holdings::Status::Noncirc.new(other_microfilm)).not_to be_noncirc
      expect(Holdings::Status::Noncirc.new(business_microfilm)).to be_noncirc
    end
  end

  describe "ARS rules" do
    let(:ars_stks) { OpenStruct.new(library: 'ARS', type: 'STKS') }
    let(:ars_other_type) { OpenStruct.new(library: 'ARS', type: 'SOMETHING') }

    it "should have identify any NON-STKS type as noncirc" do
      expect(Holdings::Status::Noncirc.new(ars_stks)).not_to be_noncirc
      expect(Holdings::Status::Noncirc.new(ars_other_type)).to be_noncirc
    end
  end

  describe "base rules" do
    describe "types" do
      let(:noncirc_types) {
        [OpenStruct.new(type: 'REF'),
         OpenStruct.new(type: 'NONCIRC'),
         OpenStruct.new(type: 'LIBUSEONLY'),
         OpenStruct.new(type: 'NH-INHOUSE')
        ]
      }
      let(:circ_type) { OpenStruct.new(type: "SOMETHING") }

      it "should identify default noncirc types as noncirculating" do
        noncirc_types.each do |noncirc_type|
          expect(Holdings::Status::Noncirc.new(noncirc_type)).to be_noncirc
        end
      end
      it "should identify other types as circulating" do
        expect(Holdings::Status::Noncirc.new(circ_type)).not_to be_noncirc
      end
    end

    describe "locations" do
      it "should identify noncirc locations an noncirculating" do
        Constants::NONCIRC_LOCS.each do |location|
          expect(Holdings::Status::Noncirc.new(OpenStruct.new(home_location: location))).to be_noncirc
        end
      end
    end
  end
end
