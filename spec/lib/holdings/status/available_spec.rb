require "spec_helper"

RSpec.describe Holdings::Status::Available do
  subject { described_class.new(OpenStruct.new(current_location:)) }

  Constants::FORCE_AVAILABLE_CURRENT_LOCS.each do |location|
    context "with #{location}" do
      let(:current_location) { Holdings::Location.new(location, folio_code: nil) }

      it { is_expected.to be_available }
    end
  end
end
