# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'marc_fields/_instrumentation' do
  subject { Capybara.string(rendered.to_s) }

  let(:instrumentation) do
    double(
      'Instrumentation',
      values: {
        'Label1' => [
          { label: 'Label1', value: 'First instrumentation' },
          { label: 'Label1', value: 'Second instrumentation' }
        ],
        'Label2' => [
          { label: 'Label2', value: 'Third instrumentation' }
        ]
      }
    )
  end

  before do
    allow(view).to receive_messages(instrumentation:)
    render
  end

  it 'has dt labels for every key in the values hash' do
    expect(subject).to have_css('dt', count: 2)
    expect(subject).to have_css('dt', text: 'Label1')
    expect(subject).to have_css('dt', text: 'Label2')
  end

  it 'has dd values for every value in the value hash' do
    expect(subject).to have_css('dd', count: 3)
    expect(subject).to have_css('dd', text: 'First instrumentation')
    expect(subject).to have_css('dd', text: 'Second instrumentation')
    expect(subject).to have_css('dd', text: 'Third instrumentation')
  end
end
