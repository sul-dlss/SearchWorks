require 'spec_helper'

describe 'marc_fields/_marc_field.html.erb' do
  subject { Capybara.string(rendered) }
  let(:marc_field) do
    double('MarcField', label: 'Field Label', values: %w(Value1 Value2))
  end
  before do
    allow(view).to receive_messages(marc_field: marc_field)
    render
  end

  it 'renders the label in a dt element' do
    expect(subject).to have_css('dt', text: 'Field Label')
  end

  it 'renders the values in individual dd elements' do
    expect(subject).to have_css('dd', count: 2)
    expect(subject).to have_css('dd', text: 'Value1')
    expect(subject).to have_css('dd', text: 'Value2')
  end
end
