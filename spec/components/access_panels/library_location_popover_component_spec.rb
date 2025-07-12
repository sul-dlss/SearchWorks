# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessPanels::LibraryLocationPopoverComponent, type: :component do
  subject(:component) { described_class.new(mhld) }

  before { render_inline(component) }

  context 'when mhld contains library holding information' do
    let(:mhld) { [Holdings::MHLD.new('GREEN -|- GRE-STACKS -|- public note -|- library has no.1 -|- latest received')] }

    it 'renders the button for displaying the popover' do
      expect(page).to have_css('button[data-bs-content][data-bs-custom-class="popover-availability"]', text: 'Summary of items')
      # the content of the popover should include the text for library has
      expect(page.find('button.btn-link')['data-bs-content']).to include('library has no.1')
    end
  end

  context 'when mhld does not contain library holding information' do
    let(:mhld) { [Holdings::MHLD.new('GREEN -|- GRE-STACKS -|- public note -|- -|- latest received')] }

    it 'does not render the button' do
      expect(page).to have_no_css('button[data-bs-content]')
      expect(page).to have_no_content('Summary of items')
    end

    describe '#render?' do
      it 'returns false' do
        expect(component).not_to be_render
      end
    end
  end
end
