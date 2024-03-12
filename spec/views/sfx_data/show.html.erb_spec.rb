# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'sfx_data/show' do
  let(:sfx_data) do
    instance_double(
      SfxData,
      targets: [
        instance_double(SfxData::Target, name: 'Target1', url: 'http://example.com', coverage: nil, embargo: nil, note: nil),
        instance_double(
          SfxData::Target,
          name: 'Target2',
          url: 'http://example2.com',
          coverage: ['Coverage Statement1', 'Coverage Statement2'],
          note: ['Note1'],
          embargo: ['Embargo1']
        )
      ]
    )
  end

  before do
    assign(:sfx_data, sfx_data)
    render
  end

  it 'renders a parent ul' do
    expect(rendered).to have_css('ul.document-metadata')
  end

  it 'renders a link within the li with the target name as text' do
    expect(rendered).to have_css('li a', text: 'Target1')
    expect(rendered).to have_css('li a', text: 'Target2')
  end

  it 'renderes the coverage statements as a nested list' do
    expect(rendered).to have_css('li ul li', text: 'Coverage Statement1')
    expect(rendered).to have_css('li ul li', text: 'Coverage Statement2')
  end

  it 'renders the notes' do
    expect(rendered).to have_css('li ul li', text: 'Note1')
  end

  it 'renders the embargo statements' do
    expect(rendered).to have_css('li ul li', text: 'Embargo1')
  end
end
