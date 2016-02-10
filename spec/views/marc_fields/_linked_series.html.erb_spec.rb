require 'spec_helper'

describe 'marc_fields/_linked_series.html.erb' do
  subject { Capybara.string(rendered) }
  let(:linked_series) do
    double(
      'LinkedSeries',
      label: 'Series',
      values: [
        { link: 'The Link Value ', extra_text: 'Some other text' },
        { link: 'Another Link Value' }
      ]
    )
  end

  before do
    allow(view).to receive_messages(linked_series: linked_series)
    render
  end

  it 'renders the label in a dt' do
    expect(subject).to have_css('dt', text: 'Series')
  end

  it 'renders each series in a dd' do
    expect(subject).to have_css('dd', count: 2)
  end

  it 'links the (stripped) link value as a phrase search to the search_series search field' do
    expect(subject).to have_css('dd a', text: 'The Link Value')
    expect(subject.first('a')['href']).to match(/q=%22The\+Link\+Value%22/)
    expect(subject.first('a')['href']).to match(/search_field=search_series/)
  end

  it 'included the extra text after the link' do
    expect(subject).to have_css('dd', text: 'The Link Value Some other text')
  end
end
