require "spec_helper"

describe Holdings::MHLD do
  let(:mhld_display) { 'GREEN -|- STACKS -|- mhld public note -|- mhld library has -|- mhld latest received' }
  let(:special_mhld) { 'GREEN -|- STACKS -|- (public),(note) -|- library-has-with-hyphens -|- ' }
  it "should return the correct elements from the MHLD combined field" do
    mhld = Holdings::MHLD.new(mhld_display)
    expect(mhld.library).to eq "GREEN"
    expect(mhld.location).to eq "STACKS"
    expect(mhld.public_note).to eq "mhld public note"
    expect(mhld.library_has).to eq "mhld library has"
    expect(mhld.latest_received).to eq "mhld latest received"
  end
  it "should replace '),(' with '), ('" do
    expect(Holdings::MHLD.new(special_mhld).public_note).to match /\), \(/
  end
  it "should append <wbr/> to hyphens" do
    expect(Holdings::MHLD.new(special_mhld).library_has).to include('-<wbr/>')
  end
  describe "#present?" do
    let(:no_mhld) { 'GREEN -|- STACKS -|- -|- -|-'}
    let(:mhld) { 'GREEN -|- STACKS -|- -|- -|- something' }
    it "should be false unless a piece of the mhld statement is available" do
      expect(Holdings::MHLD.new(no_mhld)).to_not be_present
    end
    it "should be true of any piece of the mhld is available" do
      expect(Holdings::MHLD.new(mhld)).to be_present
    end
  end
end
