require 'spec_helper'

RSpec.describe Holdings::Item do
  let(:complex_item_display) do
    'barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber -|- full_shelfkey -|- public_note -|- callnumber_type -|- course_id -|- reserve_desk -|- loan_period'
  end
  let(:item) { Holdings::Item.from_item_display_string(complex_item_display) }
  let(:methods) { [:barcode, :library, :home_location, :current_location, :type, :truncated_callnumber, :shelfkey, :reverse_shelfkey, :callnumber, :full_shelfkey, :public_note, :callnumber_type, :course_id, :reserve_desk, :loan_period] }
  let(:internet_item) { Holdings::Item.from_item_display_string(' -|- SUL -|- INTERNET -|- -|- -|- -|- abc123 -|- xyz987 -|- -|- -|- -|- LC') }
  let(:eresv_item) { Holdings::Item.from_item_display_string(' -|- SUL -|- INSTRUCTOR -|- E-RESV -|- -|- -|- abc123 -|- xyz987 -|- -|- -|- -|- LC') }

  it 'should have an attribute for each piece of the item display field' do
    methods.each do |method|
      expect(item).to respond_to(method)
    end
  end
  describe '#suppressed?' do
    let(:no_item_display) { Holdings::Item.from_item_display_string('') }

    it "should be true when the item_display doesn't exist" do
      expect(no_item_display).to be_suppressed
    end

    it 'should return false when the item_display exists' do
      expect(item).not_to be_suppressed
    end

    it 'should return true for INTERNET items' do
      expect(internet_item).to be_suppressed
    end

    it 'should return true for E-RESVs' do
      expect(eresv_item).to be_suppressed
    end
  end

  describe '#full_shelfkey' do
    it 'returns the full shelfkey' do
      expect(item.full_shelfkey).to eq('full_shelfkey')
    end

    it 'returns a string that sorts last if there is no shelfkey in the data' do
      expect(internet_item.full_shelfkey).to eq Holdings::Item::MAX_SHELFKEY
    end
  end

  describe '#on_order?' do
    it 'should return true for on-order items' do
      expect(Holdings::Item.from_item_display_string(' -|- -|- ON-ORDER -|- ON-ORDER -|-')).to be_on_order
    end

    it 'should return false for non on-order items' do
      expect(item).not_to be_on_order
    end
  end

  describe 'browsable?' do
    it 'should return false if not LC or DEWEY' do
      expect(Holdings::Item.from_item_display_string(complex_item_display)).not_to be_browsable
    end

    it 'should return false if there is no shelfkey' do
      expect(Holdings::Item.from_item_display_string('barcode -|- library -|- home_location -|- -|- -|- -|- -|- reverse_shelfkey -|- ABC123 -|- -|- -|- LC -|- -|- -|- ')).not_to be_browsable
    end

    it 'should return false if there is no reverse shelfkey' do
      expect(Holdings::Item.from_item_display_string('barcode -|- library -|- home_location -|- -|- -|- -|- shelfkey -|- -|- ABC123 -|- -|- -|- LC -|- -|- -|- ')).not_to be_browsable
    end

    it 'should return true if callnumber type is ALPHANUM' do
      alpha_num = 'barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber -|- full_shelfkey -|- public_note -|- ALPHANUM -|- course_id -|- reserve_desk -|- loan_period'
      expect(Holdings::Item.from_item_display_string(alpha_num)).to be_browsable
    end

    it 'should return false if callnumber type is INTERNET' do
      internet = 'barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber -|- full_shelfkey -|- public_note -|- INTERNET -|- course_id -|- reserve_desk -|- loan_period'
      expect(Holdings::Item.from_item_display_string(internet)).not_to be_browsable
    end
    it 'should return true if callnumber type is LC' do
      lc = 'barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber -|- full_shelfkey -|- public_note -|- LC -|- course_id -|- reserve_desk -|- loan_period'
      expect(Holdings::Item.from_item_display_string(lc)).to be_browsable
    end

    it 'should return true if callnumber type is DEWEY' do
      dewey = 'barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber -|- full_shelfkey -|- public_note -|- DEWEY -|- course_id -|- reserve_desk -|- loan_period'
      expect(Holdings::Item.from_item_display_string(dewey)).to be_browsable
    end

    it 'should return true if the item is an internet resource' do
      expect(internet_item).to be_browsable
    end
  end

  describe '#callnumber' do
    let(:item_without_callnumber) { Holdings::Item.from_item_display_string('barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- -|- full_shelfkey ') }
    let(:lane_online_item) { Holdings::Item.from_item_display_string(' -|- LANE-MED -|- LANE-ECOLL -|- -|- ONLINE -|- -|- abc123 -|- xyz987 -|- -|- -|- -|- LC') }

    it "should return '(no call number) if the callnumber is blank" do
      expect(item_without_callnumber.callnumber).to eq '(no call number)'
    end

    it 'returns "eResource" when the home location is INTERNET' do
      expect(internet_item.callnumber).to eq 'eResource'
    end

    it 'returns "eResource" when the item type is ONLINE' do
      expect(lane_online_item.callnumber).to eq 'eResource'
    end
  end

  describe '#status' do
    let(:status) { item.status }

    it 'should return a Holdings::Status object' do
      expect(status).to be_a Holdings::Status
    end

    it 'should return an availability_class string' do
      expect(status.availability_class).to eq 'unknown'
    end
  end

  describe '#live_status?' do
    it 'should identify material not in LANE-MED for live lookup' do
      expect(Holdings::Item.from_item_display_string('barcode -|- GREEN -|- STACKS -|- -|-')).to be_live_status
    end

    it 'should identify material in LANE-MED to not do a live lookup' do
      expect(Holdings::Item.from_item_display_string('barcode -|- LANE-MED -|- STACKS -|- -|-')).not_to be_live_status
    end
  end

  describe 'treat_current_location_as_home_location?' do
    it "should return true if an item's current location is in the list of locations" do
      Constants::CURRENT_HOME_LOCS.each do |location|
        expect(Holdings::Item.from_item_display_string("barcode -|- library -|- home_location -|- #{location} -|-").treat_current_location_as_home_location?).to be_truthy
      end
    end

    it 'should replace the home location with the current location' do
      expect(Holdings::Item.from_item_display_string('barcode -|- library -|- home_location -|- IC-DISPLAY -|-').home_location).to eq 'IC-DISPLAY'
    end
  end

  describe 'public_note' do
    let(:public_note) { Holdings::Item.from_item_display_string('barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber -|- full_shelfkey -|- .PUBLIC. The Public Note -|- callnumber_type -|- course_id -|- reserve_desk -|- loan_period') }

    it 'should remove the .PUBLIC. string from the public note field' do
      expect(public_note.public_note).to eq 'The Public Note'
      expect(public_note.public_note).not_to include 'PUBLIC'
    end
  end

  describe 'reserves' do
    it 'should change the library for an item that is at a reserve desk' do
      expect(Holdings::Item.from_item_display_string('barcode -|- GREEN -|- home_location -|- ART-RESV -|-').library).to eq 'ART'
    end
  end

  describe '#on_reserve?' do
    it 'should return true when an item is populated with reserve desks and loan period' do
      expect(item).to be_on_reserve
    end

    it 'should return false when an item is not populated with reserve desk and loan period' do
      expect(Holdings::Item.from_item_display_string('123 -|- abc')).not_to be_on_reserve
    end
  end

  describe 'stackmapable?' do
    # 0 barcode -|- 1 library -|- 2 home location -|- 3 current location
    it 'when a library is stackmapable and the home location is not skipped' do
      expect(described_class.from_item_display_string('barcode -|- GREEN -|- STACKS')).to be_stackmapable
      expect(described_class.from_item_display_string('barcode -|- ART -|- STACKS')).to be_stackmapable
      expect(described_class.from_item_display_string('barcode -|- EAST-ASIA -|- KOREAN')).to be_stackmapable
    end

    it 'when a library is not stackmapable' do
      expect(described_class.from_item_display_string('barcode -|- UNKNOWN -|- STACKS')).not_to be_stackmapable
    end

    it 'when the library is stackmapable but the home location is globally skipped' do
      expect(described_class.from_item_display_string('barcode -|- GREEN -|- GREEN-RESV')).not_to be_stackmapable
    end

    it 'when the library is stackmapable but the home location is locally skipped' do
      expect(described_class.from_item_display_string('barcode -|- ART -|- MEDIA')).not_to be_stackmapable
    end

    it 'when the library is stackmapable but the home location is locally skipped for a different library' do
      expect(described_class.from_item_display_string('barcode -|- GREEN -|- MEDIA')).to be_stackmapable
    end
  end

  describe 'zombie libraries' do
    let(:blank) { Holdings::Item.from_item_display_string('123 -|- -|- LOCATION -|- ') }
    let(:sul) { Holdings::Item.from_item_display_string('123 -|- SUL -|- LOCATION -|- ') }
    let(:physics) { Holdings::Item.from_item_display_string('123 -|- PHYSICS -|- LOCATION -|- ') }

    it 'should view blank libraries as a zombie library' do
      expect(blank.library).to eq 'ZOMBIE'
    end

    it 'should view blank libraries as a zombie library' do
      expect(sul.library).to eq 'ZOMBIE'
    end

    it 'should view blank libraries as a zombie library' do
      expect(physics.library).to eq 'ZOMBIE'
    end
  end

  describe '#as_json' do
    let(:as_json) { Holdings::Item.from_item_display_string(complex_item_display).as_json }

    it "should return a hash with all of the item's public reader methods" do
      expect(as_json).to be_a Hash
      expect(as_json[:callnumber]).to eq 'callnumber'
    end

    it 'should return an as_json hash for status' do
      expect(as_json[:status]).to be_a Hash
      expect(as_json[:status]).to have_key :availability_class
      expect(as_json[:status]).to have_key :status_text
    end

    it 'should return an as_json hash for current_location' do
      expect(as_json[:current_location]).to be_a Hash
      expect(as_json[:current_location]).to have_key :code
      expect(as_json[:current_location]).to have_key :name
    end
  end

  describe '#circulates?' do
    context 'for libaries/locations that are configured to have request links' do
      subject(:item) { Holdings::Item.from_item_display_string('123 -|- GREEN -|- LOCKED-STK -|- -|- STKS-MONO') }

      it { is_expected.to be_circulates }
    end

    context 'when the item has a non-circulating item type' do
      subject(:item) { Holdings::Item.from_item_display_string('123 -|- GREEN -|- LOCKED-STK -|- -|- NONCIRC') }

      it { is_expected.not_to be_circulates }
    end

    context 'when an item is in a location within a library that specifies location specific item types' do
      subject(:item) { Holdings::Item.from_item_display_string('123 -|- SAL -|- UNCAT -|- -|- NONCIRC') }

      it { is_expected.to be_circulates }
    end

    context 'when an item is in a location and with a library specific item type that circulates' do
      subject(:item) { Holdings::Item.from_item_display_string('123 -|- ART -|- STACKS -|- -|- MEDIA') }

      it { is_expected.to be_circulates }
    end
  end

  describe '#live_lookup_item_id' do
    let(:document) { SolrDocument.new }

    subject(:item) { described_class.from_item_display_string('36105232609540 -|- GREEN -|- GRE-STACKS', document:) }

    before do
      allow(document).to receive(:folio_items).and_return([])
    end

    it 'returns the item barcode' do
      expect(item.live_lookup_item_id).to eq '36105232609540'
    end
  end

  context 'with data from FOLIO' do
    let(:folio_location) {
      Folio::Location.from_dynamic(
        {
          'id' => '4573e824-9273-4f13-972f-cff7bf504217',
          'code' => 'GRE-STACKS',
          'name' => 'Green Library Stacks',
          'institution' => {
            'id' => '8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929',
            'code' => 'SU',
            'name' => 'Stanford University'
          },
          'campus' => {
            'id' => 'c365047a-51f2-45ce-8601-e421ca3615c5',
            'code' => 'SUL',
            'name' => 'Stanford Libraries'
          },
          'library' => {
            'id' => 'f6b5519e-88d9-413e-924d-9ed96255f72e',
            'code' => 'GREEN',
            'name' => 'Cecil H. Green'
          }
        }
      )
    }
    let(:folio_item) {
      Folio::Item.new(
        id: '64d4220b-ebae-5fb0-971c-0f98f6d9cc93',
        status: 'Available',
        barcode: '36105232609540',
        material_type: Folio::Item::MaterialType.new(id: '1a54b431-2e4f-452d-9cae-9cee66c9a892', name: 'book'),
        permanent_loan_type: Folio::Item::LoanType.new(id: '2b94c631-fca9-4892-a730-03ee529ffe27', name: 'Can circulate'),
        effective_location: folio_location
      )
    }
    let(:document) { SolrDocument.new }

    subject(:item) { described_class.from_item_display_string('36105232609540 -|- GREEN -|- GRE-STACKS', document:) }

    before do
      allow(document).to receive(:folio_items).and_return([folio_item])
    end

    describe '#material_type' do
      it 'returns the material type from FOLIO' do
        expect(item.material_type.name).to eq 'book'
      end
    end

    describe '#loan_type' do
      it 'returns the loan type from FOLIO' do
        expect(item.loan_type.name).to eq 'Can circulate'
      end
    end

    describe '#effective_location' do
      it 'returns the effective location from FOLIO' do
        expect(item.effective_location.library.code).to eq 'GREEN'
        expect(item.effective_location.code).to eq 'GRE-STACKS'
      end
    end

    describe '#live_lookup_item_id' do
      it 'returns the item uuid from FOLIO' do
        expect(item.live_lookup_item_id).to eq '64d4220b-ebae-5fb0-971c-0f98f6d9cc93'
      end
    end
  end
end
