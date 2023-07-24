require "spec_helper"

RSpec.describe Holdings::Status::Unavailable do
  describe "unavailable libraries" do
    subject {
      Holdings::Status::Unavailable.new(
        OpenStruct.new(library: "ZOMBIE")
      )
    }

    it { is_expected.to be_unavailable }
  end

  describe "unavailable home locations" do
    Constants::UNAVAILABLE_LOCS.each do |home_location|
      context "with #{home_location}" do
        subject { Holdings::Status::Unavailable.new(OpenStruct.new(home_location:)) }

        it { is_expected.to be_unavailable }
      end
    end
  end

  describe "unavailable current locations" do
    subject { Holdings::Status::Unavailable.new(OpenStruct.new(current_location:)) }

    Settings.unavailable_current_locations.default.each do |location|
      context "with #{location}" do
        let(:current_location) { Holdings::Location.new(location, folio_code: nil) }

        it { is_expected.to be_unavailable }
      end
    end

    context 'with -LOAN' do
      let(:current_location) { Holdings::Location.new("SOMETHING-LOAN", folio_code: nil) }

      it { is_expected.to be_unavailable }
    end

    context 'with SPE--LOAN' do
      let(:current_location) { Holdings::Location.new("SPE-LOAN", folio_code: nil) }

      it { is_expected.not_to be_unavailable }
    end
  end
end
