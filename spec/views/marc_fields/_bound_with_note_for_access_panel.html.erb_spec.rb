require 'rails_helper'

RSpec.describe 'marc_fields/_bound_with_note_for_access_panel' do
  subject { Capybara.string(rendered) }

  let(:bound_with_note) do
    double(
      'BoundWithNote',
      values: [
        { value: '12345 Bound With', id: '12345' }
      ]
    )
  end

  before do
    allow(view).to receive_messages(bound_with_note_for_access_panel: bound_with_note)
    render
  end

  it 'replaces the ID in the value with a link' do
    expect(subject).to have_link('12345', href: '/view/12345')
    expect(subject).to have_content('12345 Bound With')
  end
end
