require 'spec_helper'

describe Holdings::Callnumber do
  let(:complex_item_display) do
    'barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber -|- full_shelfkey -|- public_note -|- callnumber_type -|- course_id -|- reserve_desk -|- loan_period'
  end
  let(:callnumber) { Holdings::Callnumber.new(complex_item_display) }
  let(:methods) { [:barcode, :library, :home_location, :current_location, :type, :truncated_callnumber, :shelfkey, :reverse_shelfkey, :callnumber, :full_shelfkey, :public_note, :callnumber_type, :course_id, :reserve_desk, :loan_period] }
  let(:internet_callnumber) { Holdings::Callnumber.new(' -|- SUL -|- INTERNET -|- -|- -|- -|- abc123 -|- xyz987 -|- -|- -|- -|- LC') }
  let(:eresv_callnumber) { Holdings::Callnumber.new(' -|- SUL -|- INSTRUCTOR -|- E-RESV -|- -|- -|- abc123 -|- xyz987 -|- -|- -|- -|- LC') }

  it 'should have an attribute for each piece of the item display field' do
    methods.each do |method|
      expect(callnumber).to respond_to(method)
    end
  end
  describe '#present?' do
    let(:no_item_display) { Holdings::Callnumber.new('') }

    it "should be false when the item_display doesn't exist" do
      expect(no_item_display).not_to be_present
    end

    it 'should return true when the item_display exists' do
      expect(callnumber).to be_present
    end

    it 'should return false for INTERNET callnumbers' do
      expect(internet_callnumber).not_to be_present
    end

    it 'should return false for E-RESVs' do
      expect(eresv_callnumber).not_to be_present
    end
  end

  describe '#on_order?' do
    it 'should return true for on-order items' do
      expect(Holdings::Callnumber.new(' -|- -|- ON-ORDER -|- ON-ORDER -|-')).to be_on_order
    end

    it 'should return false for non on-order items' do
      expect(callnumber).not_to be_on_order
    end
  end

  describe 'browsable?' do
    it 'should return false if not LC or DEWEY' do
      expect(Holdings::Callnumber.new(complex_item_display)).not_to be_browsable
    end

    it 'should return false if there is no shelfkey' do
      expect(Holdings::Callnumber.new('barcode -|- library -|- home_location -|- -|- -|- -|- -|- reverse_shelfkey -|- ABC123 -|- -|- -|- LC -|- -|- -|- ')).not_to be_browsable
    end

    it 'should return false if there is no reverse shelfkey' do
      expect(Holdings::Callnumber.new('barcode -|- library -|- home_location -|- -|- -|- -|- shelfkey -|- -|- ABC123 -|- -|- -|- LC -|- -|- -|- ')).not_to be_browsable
    end

    it 'should return true if callnumber type is ALPHANUM' do
      alpha_num = 'barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber -|- full_shelfkey -|- public_note -|- ALPHANUM -|- course_id -|- reserve_desk -|- loan_period'
      expect(Holdings::Callnumber.new(alpha_num)).to be_browsable
    end

    it 'should return false if callnumber type is INTERNET' do
      internet = 'barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber -|- full_shelfkey -|- public_note -|- INTERNET -|- course_id -|- reserve_desk -|- loan_period'
      expect(Holdings::Callnumber.new(internet)).not_to be_browsable
    end
    it 'should return true if callnumber type is LC' do
      lc = 'barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber -|- full_shelfkey -|- public_note -|- LC -|- course_id -|- reserve_desk -|- loan_period'
      expect(Holdings::Callnumber.new(lc)).to be_browsable
    end

    it 'should return true if callnumber type is DEWEY' do
      dewey = 'barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber -|- full_shelfkey -|- public_note -|- DEWEY -|- course_id -|- reserve_desk -|- loan_period'
      expect(Holdings::Callnumber.new(dewey)).to be_browsable
    end

    it 'should return true if the item is an internet resource' do
      expect(internet_callnumber).to be_browsable
    end
  end

  describe '#callnumber' do
    let(:no_callnumber) { Holdings::Callnumber.new('barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- -|- full_shelfkey ') }

    it "should return '(no call number) if the callnumber is blank" do
      expect(no_callnumber.callnumber).to eq '(no call number)'
    end

    it 'returns "eResource" when the home location is INTERNET ' do
      expect(internet_callnumber.callnumber).to eq 'eResource'
    end
  end

  describe '#status' do
    let(:status) { callnumber.status }

    it 'should return a Holdings::Status object' do
      expect(status).to be_a Holdings::Status
    end

    it 'should return an availability_class string' do
      expect(status.availability_class).to eq 'unknown'
    end
  end

  describe '#live_status?' do
    it 'should identify material not in LANE-MED for live lookup' do
      expect(Holdings::Callnumber.new('barcode -|- GREEN -|- STACKS -|- -|-')).to be_live_status
    end

    it 'should identify material in LANE-MED to not do a live lookup' do
      expect(Holdings::Callnumber.new('barcode -|- LANE-MED -|- STACKS -|- -|-')).not_to be_live_status
    end
  end

  describe 'treat_current_location_as_home_location?' do
    it "should return true if an item's current location is in the list of locations" do
      Constants::CURRENT_HOME_LOCS.each do |location|
        expect(Holdings::Callnumber.new("barcode -|- library -|- home_location -|- #{location} -|-").treat_current_location_as_home_location?).to be_truthy
      end
    end

    it 'should replace the home location with the current location' do
      expect(Holdings::Callnumber.new('barcode -|- library -|- home_location -|- IC-DISPLAY -|-').home_location).to eq 'IC-DISPLAY'
    end
  end

  describe 'public_note' do
    let(:public_note) { Holdings::Callnumber.new('barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber -|- full_shelfkey -|- .PUBLIC. The Public Note -|- callnumber_type -|- course_id -|- reserve_desk -|- loan_period') }

    it 'should remove the .PUBLIC. string from the public note field' do
      expect(public_note.public_note).to eq 'The Public Note'
      expect(public_note.public_note).not_to include 'PUBLIC'
    end
  end

  describe 'reserves' do
    it 'should use the pseudo home location if an item is has a reserve desk current location' do
      expect(Holdings::Callnumber.new('barcode -|- library -|- home_location -|- ART-RESV -|-').home_location).to eq 'SW-RESERVE-DESK'
    end

    it 'should change the library for an item that is at a reserve desk' do
      expect(Holdings::Callnumber.new('barcode -|- GREEN -|- home_location -|- ART-RESV -|-').library).to eq 'ART'
    end
  end

  describe '#on_reserve?' do
    it 'should return true when an item is populated with reserve desks and loan period' do
      expect(callnumber).to be_on_reserve
    end

    it 'should return false when an item is not populated with reserve desk and loan period' do
      expect(Holdings::Callnumber.new('123 -|- abc')).not_to be_on_reserve
    end
  end

  describe 'request status' do
    it 'should respond to #show_item_level_request_link? from the Holdings::Requestable class' do
      expect(Holdings::Callnumber.new('123 -|- abc -|- -|- -|- -|-')).not_to be_show_item_level_request_link
    end
  end

  describe 'stackmapable?' do
    # 0 barcode -|- 1 library -|- 2 home location -|- 3 current location
    it 'when a library is stackmapable and the home location is not skipped' do
      expect(described_class.new('barcode -|- GREEN -|- STACKS')).to be_stackmapable
      expect(described_class.new('barcode -|- ART -|- STACKS')).to be_stackmapable
      expect(described_class.new('barcode -|- EAST-ASIA -|- KOREAN')).to be_stackmapable
    end

    it 'when a library is not stackmapable' do
      expect(described_class.new('barcode -|- UNKNOWN -|- STACKS')).not_to be_stackmapable
    end

    it 'when the library is stackmapable but the home location is globally skipped' do
      expect(described_class.new('barcode -|- GREEN -|- GREEN-RESV')).not_to be_stackmapable
    end

    it 'when the library is stackmapable but the home location is locally skipped' do
      expect(described_class.new('barcode -|- ART -|- MEDIA')).not_to be_stackmapable
    end

    it 'when the library is stackmapable but the home location is locally skipped for a different library' do
      expect(Constants::STACKMAP_SKIPLIST['GREEN']).to be_nil
      expect(Constants::STACKMAP_SKIPLIST['ART']).to include 'MEDIA'
      expect(described_class.new('barcode -|- GREEN -|- MEDIA')).to be_stackmapable
    end
  end

  describe 'zombie libraries' do
    let(:blank) { Holdings::Callnumber.new('123 -|- -|- LOCATION -|- ') }
    let(:sul) { Holdings::Callnumber.new('123 -|- SUL -|- LOCATION -|- ') }
    let(:physics) { Holdings::Callnumber.new('123 -|- PHYSICS -|- LOCATION -|- ') }

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
    let(:as_json) { Holdings::Callnumber.new(complex_item_display).as_json }

    it 'should return a hash with all of the callnumbers public reader methods' do
      expect(as_json).to be_a Hash
      expect(as_json[:present?]).to be true
      expect(as_json[:browsable?]).to be false
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
end
