# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessPanels::OtherListingsComponent, type: :component do
  include MarcMetadataFixtures

  let(:component) { described_class.new(document:) }

  let(:document_hash) { { id: '123' } }
  let(:document) { SolrDocument.new(document_hash) }
  let(:earthworks) { true }
  let(:druid) { 'bd285ct9109' }

  before { render_inline(component) }

  it 'does not render when there is not a druid' do
    expect(rendered_content).to eq ""
  end

  context 'there is a druid' do
    let(:document_hash) do
      { druid: 'hj948rn6493' }
    end

    it 'displays a link to the PURL' do
      expect(page).to have_link('Stanford Digital Repository', href: 'https://purl.stanford.edu/hj948rn6493')
    end
  end
end
