# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessPanels::LibraryLocationPopoverComponent, type: :component do
  subject(:component) { described_class.new(mhld: mhld) }

  before { render_inline(component) }

  context 'when mhld contains library holding information' do
    let(:mhld) { [Holdings::MHLD.new('SAL3 -|- SAL3-STACKS -|- -|- v.1(1984)-v.3(1986) <no.29,33,39 in series> -|-')] }

    it 'renders the button for displaying the popover' do
      expect(page).to have_css('button[data-bs-content][data-bs-custom-class="popover-availability"]', text: 'Summary of items')
      expect(page.find('button.btn-link')['data-bs-content']).to eq('v.1(1984)-<wbr/>v.3(1986) no.29, 33, 39 in series')
    end
  end

  context 'when mhld does not contain library holding information' do
    let(:mhld) { [Holdings::MHLD.new('GREEN -|- GRE-STACKS -|- public note -|- -|- latest received')] }

    it 'does not render the button' do
      expect(page).to have_no_css('button[data-bs-content]')
      expect(page).to have_no_text('Summary of items')
    end
  end
end
