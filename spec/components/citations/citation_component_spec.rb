# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Citations::CitationComponent, type: :component do
  let(:component) { described_class.new(citations:) }

  let(:citations) do
    { 'mla' => 'MLA Citation', 'apa' => 'APA Citation' }
  end

  subject(:page) { render_inline(component) }

  it 'includes the citations on the page' do
    expect(page).to have_css('h4', text: 'MLA')
    expect(page).to have_css('h4', text: 'APA')
    expect(page).to have_css('div', text: 'MLA Citation')
    expect(page).to have_css('div', text: 'APA Citation')
  end
end
