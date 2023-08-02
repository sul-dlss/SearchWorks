require "spec_helper"

RSpec.describe Holdings::Status do
  let(:status) { Holdings::Status.new(OpenStruct.new) }

  describe "::Available" do
    before do
      allow_any_instance_of(Holdings::Status::Available).to receive(:available?).and_return(true)
    end

    it "should have the available class" do
      expect(status.availability_class).to eq 'available'
    end
    it "should have the available status text" do
      expect(status.status_text).to eq 'Available'
    end
    it "should be available" do
      expect(status).to be_available
    end
  end

  describe "::Noncirc" do
    before do
      allow_any_instance_of(Holdings::Status::Noncirc).to receive(:noncirc?).and_return(true)
    end

    it "should have the noncirc class" do
      expect(status.availability_class).to eq 'noncirc'
    end
    it "should have the noncirc status text" do
      expect(status.status_text).to eq 'In-library use'
    end
    it "should be noncirc" do
      expect(status).to be_noncirc
    end
  end

  describe "::NoncircPage" do
    before do
      allow_any_instance_of(Holdings::Status::NoncircPage).to receive(:noncirc_page?).and_return(true)
    end

    it "should have the noncirc_page class" do
      expect(status.availability_class).to eq 'noncirc_page'
    end
    it "should have the noncirc_page status text" do
      expect(status.status_text).to eq 'In-library use'
    end
    it "should be noncirc_page" do
      expect(status).to be_noncirc_page
    end
  end

  describe "::Pageable" do
    subject { status }

    before do
      allow_any_instance_of(Holdings::Status::DeliverFromOffsite).to receive(:deliver_from_offsite?).and_return(true)
    end

    it "has the deliver-from-offsite class" do
      expect(status.availability_class).to eq 'deliver-from-offsite'
    end
    it "has the page status text" do
      expect(status.status_text).to eq 'Available'
    end
    it { is_expected.to be_deliver_from_offsite }
  end

  describe "CDL" do
    let(:status) { Holdings::Status.new(OpenStruct.new(home_location: 'CDL')) }

    it "should have the unavailable class" do
      expect(status.availability_class).to eq 'unavailable cdl'
    end
    it "should have the unavailable status text" do
      expect(status.status_text).to eq 'Physical copy unavailable'
    end
    it "should be cdl" do
      expect(status).to be_cdl
    end
  end

  describe "::Unavailable" do
    before do
      allow_any_instance_of(Holdings::Status::Unavailable).to receive(:unavailable?).and_return(true)
    end

    it "should have the unavailable class" do
      expect(status.availability_class).to eq 'unavailable'
    end
    it "should have the unavailable status text" do
      expect(status.status_text).to eq 'Unavailable'
    end
    it "should be unavailable" do
      expect(status).to be_unavailable
    end
  end

  context "without matching any other status" do
    subject { status.availability_class }

    it { is_expected.to eq 'unknown' }
  end

  describe 'precedence' do
    subject { Holdings::Status.new(item) }

    describe 'unavailable' do
      let(:item) do
        instance_double(
          Holdings::Item,
          library: 'SAL3',
          home_location: 'STACKS',
          current_location: instance_double(Holdings::Location, code: 'LOST-ASSUM'),
          type: 'STACKS'
        )
      end

      it 'takes precedence over things like page' do
        expect(subject.availability_class).to eq 'unavailable'
      end
    end
  end

  describe '#as_json' do
    let(:as_json) { status.as_json }

    it 'should return a json hash with the availability class and status text' do
      expect(as_json).to have_key :availability_class
      expect(as_json).to have_key :status_text
    end
  end
end
