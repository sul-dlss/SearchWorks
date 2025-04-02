# frozen_string_literal: true

require "rails_helper"

RSpec.describe Record::MarcContentAdviceComponent, type: :component do
  include MarcMetadataFixtures

  let(:component) { described_class.new(document:) }

  let(:document) do
    SolrDocument.new(id: '123', summary_struct:)
  end

  subject(:page) { render_inline(component) }

  context 'marc_json_struct has content advice field' do
    let(:summary_struct) {
      [
        { label: 'Summary', fields: [{ field: 'Summary of content' }] },
        { label: 'Content advice', fields: [{ field: 'Warning about the content' }] }
      ]
    }

    it 'creates a content warning' do
      expect(page).to have_css('.content-advice')
      expect(page).to have_content('Warning about the content')
      expect(page).to have_css('strong', text: 'Content advice: ')
    end
  end

  context 'marc_json_struct does not have content advice field' do
    let(:summary_struct) { [] }

    it 'does not render' do
      expect(page.to_html).to be_empty
    end
  end
end
