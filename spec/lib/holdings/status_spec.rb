require "spec_helper"

RSpec.describe Holdings::Status do
  let(:status) { Holdings::Status.new(OpenStruct.new) }

  describe '#as_json' do
    let(:as_json) { status.as_json }

    it 'should return a json hash with the availability class and status text' do
      expect(as_json).to have_key :availability_class
      expect(as_json).to have_key :status_text
    end
  end
end
