# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Citations::MultipleCitationsComponent, type: :component do
  let(:component) { described_class.new(documents:, oclc_citations:) }

  let(:oclc_citations) do
    { '123456' => { 'mla' => ['MLA Citation 1'],
                    'apa' => ['APA Citation 1'] } }
  end
  let(:document_with_oclc_citations) do
    instance_double(SolrDocument, oclc_number: '123456', eds?: false, mods_citations: {}, fetch: 'OCLC Title')
  end
  let(:document_with_mods_citations) do
    instance_double(SolrDocument, oclc_number: nil, eds?: false,
                                  mods_citations: { 'preferred' => ['Preferred Citation 1'] },
                                  fetch: 'MODS Title')
  end
  let(:documents) { [document_with_oclc_citations, document_with_mods_citations] }

  subject(:page) { render_inline(component) }

  describe '#citations' do
    it 'returns the citations for the document' do
      expect(component.citations(document_with_oclc_citations)).to eq('mla' => ['MLA Citation 1'], 'apa' => ['APA Citation 1'])
      expect(component.citations(document_with_mods_citations)).to eq('preferred' => ['Preferred Citation 1'])
    end
  end

  it 'renders the citations to the page' do
    expect(page).to have_css('h3', text: 'OCLC Title').once
    expect(page).to have_css('h3', text: 'MODS Title').once
    expect(page).to have_css('h4', text: 'Preferred citation')
    expect(page).to have_css('div', text: 'Preferred Citation 1')
    expect(page).to have_css('h4', text: 'MLA')
    expect(page).to have_css('div', text: 'MLA Citation 1')
    expect(page).to have_css('h4', text: 'APA')
    expect(page).to have_css('div', text: 'APA Citation 1')
  end
end
