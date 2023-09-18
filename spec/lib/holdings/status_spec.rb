require "spec_helper"

RSpec.describe Holdings::Status do
  let(:status) { described_class.new(item) }

  let(:item) { Holdings::Item.new({}, folio_item:) }

  let(:folio_item) do
    Folio::Item.new(
      id: '123', status: folio_status, barcode: '5555555',
      material_type: Folio::Item::MaterialType.new(id: 'book', name: 'parchment'),
      permanent_loan_type: Folio::Item::LoanType.new(id: '7day', name: '7-day loan'),
      effective_location: Folio::Location.new(id: location_id, code: 'GRE-STACKS',
                                              campus: Folio::Location::Campus.new(id: '4444', code: 'SU', name: 'Stanford'),
                                              library: Folio::Library.new(id: 'green', code: 'GREEN', name: 'Cecil R. Green Library'))
    )
  end
  let(:location_id) { '4573e824-9273-4f13-972f-cff7bf504217' } # GRE-STACKS
  let(:folio_status) { 'Available' }
  let(:item_loan_policy) { { 'loanable' => true } }

  before do
    allow(Folio::CirculationRules::PolicyService.instance).to receive(:item_loan_policy).and_return(item_loan_policy)
  end

  describe "when the holding is available" do
    it "has the available class" do
      expect(status.availability_class).to eq 'available'
    end
    it "has the available status text" do
      expect(status.status_text).to eq 'Available'
    end
  end

  describe "when the holding is non-circulating" do
    let(:item_loan_policy) { { 'loanable' => false } }

    it "has the noncirc class" do
      expect(status.availability_class).to eq 'noncirc'
    end
    it "has the noncirc status text" do
      expect(status.status_text).to eq 'In-library use'
    end
  end

  describe "when the holding is non-circulating, but pageable" do
    let(:item_loan_policy) { { 'loanable' => false } }
    let(:location_id) { '69ff02b2-362f-40d5-96ac-0f514f15a2e9' } # LANE-SAL3

    it "has the noncirc_page class" do
      expect(status.availability_class).to eq 'noncirc_page'
    end
    it "has the noncirc_page status text" do
      expect(status.status_text).to eq 'In-library use'
    end
  end

  describe "when the holding is pageable" do
    subject { status }

    let(:location_id) { '45daa686-823a-4ad5-b187-d7878bebf00d' } # SAL3-PAGE-MA

    it "has the deliver-from-offsite class" do
      expect(status.availability_class).to eq 'deliver-from-offsite'
    end
    it "has the page status text" do
      expect(status.status_text).to eq 'Available'
    end
  end

  context "when On order" do
    let(:folio_status) { 'On order' }

    it "has the unavailable class" do
      expect(status.availability_class).to eq 'unavailable'
    end
    it "has the unavailable status text" do
      expect(status.status_text).to eq 'Unavailable'
    end
  end

  context "without matching any other status" do
    subject { status.availability_class }

    it { is_expected.to eq 'unknown' }
  end

  describe '#as_json' do
    let(:as_json) { status.as_json }

    it 'should return a json hash with the availability class and status text' do
      expect(as_json).to have_key :availability_class
      expect(as_json).to have_key :status_text
    end
  end
end
