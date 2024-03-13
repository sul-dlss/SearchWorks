# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Holdings::MHLD do
  let(:mhld_display) { 'GREEN -|- STACKS -|- mhld public note -|- mhld library has -|- mhld latest received' }
  let(:special_mhld) { 'GREEN -|- STACKS -|- (public),(note),no.17,no.14 -|- library-has-with-hyphens and <html> entities -|- ' }
  let(:zombie_mhld) { 'PHYSICS -|- STACKS -|- mhld public note -|- mhld library has -|- mhld latest received' }
  let(:long_mhld) do
    "SAL3 -|- PAGE-AS -|-  -|- v.1:no.3(1965:Sept.20)-v.1:no.4(1965:Oct.18);v.1:no.6(1965:Nov.17)-v.1:no.11(1966:May9),v.2:no.2(1966:Aug.8)-v.6:no.6(1970:Dec./1971:Jan.) -|- "
  end

  it 'should return the correct elements from the MHLD combined field' do
    mhld = Holdings::MHLD.new(mhld_display)
    expect(mhld.library).to eq 'GREEN'
    expect(mhld.location).to eq 'STACKS'
    expect(mhld.public_note).to eq 'mhld public note'
    expect(mhld.library_has).to eq 'mhld library has'
    expect(mhld.latest_received).to eq 'mhld latest received'
  end

  it 'should escape HTML enteties in MHLD data' do
    library_has = Holdings::MHLD.new(special_mhld).library_has
    expect(library_has).not_to include('<html>')
    expect(library_has).to include('&lt;html&gt;')
  end

  it "should replace '),(' with '), ('" do
    expect(Holdings::MHLD.new(special_mhld).public_note).to match(/\), \(/)
  end

  it "should replace ',' with ', '" do
    expect(Holdings::MHLD.new(special_mhld).public_note).to match(/no\.17, no\.14/)
  end

  it "should replace ';' with '; '" do
    expect(Holdings::MHLD.new(long_mhld).library_has).to match(/v.1:no.3\(1965:Sept.20\)-<wbr\/>v.1:no.4\(1965:Oct.18\); v.1:no.6\(1965:Nov.17\)/)
  end

  it 'should append <wbr/> to hyphens' do
    expect(Holdings::MHLD.new(special_mhld).library_has).to include('-<wbr/>')
  end

  it 'should include mhlds from zombie libraries' do
    zombie = Holdings::MHLD.new(zombie_mhld)
    expect(zombie).to be_present
    expect(zombie.library).to eq 'ZOMBIE'
    expect(Holdings::MHLD.new(mhld_display).library).to eq 'GREEN'
  end

  describe '#present?' do
    let(:no_mhld) { 'GREEN -|- STACKS -|- -|- -|-' }
    let(:mhld) { 'GREEN -|- STACKS -|- -|- -|- something' }

    it 'should be false unless a piece of the mhld statement is available' do
      expect(Holdings::MHLD.new(no_mhld)).not_to be_present
    end

    it 'should be true of any piece of the mhld is available' do
      expect(Holdings::MHLD.new(mhld)).to be_present
    end
  end
end
