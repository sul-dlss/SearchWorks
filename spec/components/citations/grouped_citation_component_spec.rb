# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Citations::GroupedCitationComponent, type: :component do
  let(:component) { described_class.new(citations:) }

  let(:citations) do
    [{ 'mla' => 'MLA Citation 1', 'apa' => 'APA Citation 1' },
     { 'mla' => 'MLA Citation 2', 'apa' => 'APA Citation 2' },
     { 'preferred' => 'Preferred Citation 1' }]
  end

  subject(:page) { render_inline(component) }

  it 'includes the citations on the page' do
    expect(page).to have_css('h4', text: 'Preferred citation').once
    expect(page).to have_css('div', text: 'Preferred Citation 1')
    expect(page).to have_css('h4', text: 'MLA').once
    expect(page).to have_css('div', text: 'MLA Citation 1')
    expect(page).to have_css('div', text: 'MLA Citation 2')
    expect(page).to have_css('h4', text: 'APA').once
    expect(page).to have_css('div', text: 'APA Citation 1')
    expect(page).to have_css('div', text: 'APA Citation 2')
  end

  describe '#grouped_citations' do
    it 'groups the citations by style and puts the preferred style first' do
      expect(component.grouped_citations).to eq('preferred' => ['Preferred Citation 1'],
                                                'mla' => ['MLA Citation 1', 'MLA Citation 2'],
                                                'apa' => ['APA Citation 1', 'APA Citation 2'])
    end
  end
end
