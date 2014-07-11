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
end
