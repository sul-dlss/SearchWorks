# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Record::Cocina::FieldComponent, type: :component do
  subject(:page) { render_inline(described_class.new(field: field)) }

  let(:field) do
    instance_double(
      CocinaDisplay::DisplayData,
      label: 'Related publications',
      values: ['The author, <i>The title</i>, https://example.com/publication']
    )
  end

  it 'renders allowed HTML and auto-links URLs' do
    expect(page).to have_css('dd i', text: 'The title')
    expect(page).to have_link('https://example.com/publication', href: 'https://example.com/publication')
  end

  context 'with unsafe HTML' do
    let(:field) do
      instance_double(CocinaDisplay::DisplayData, label: 'Note', values: ['<script>alert("unsafe")</script>'])
    end

    it 'sanitizes the value' do
      expect(page).to have_no_css('script')
      expect(page).to have_text('alert("unsafe")')
    end
  end
end
