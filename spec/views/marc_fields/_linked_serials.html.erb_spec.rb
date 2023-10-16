require 'rails_helper'

RSpec.describe 'marc_fields/_linked_serials' do
  subject { Capybara.string(rendered) }

  let(:linked_serial) do
    double(
      'LinkedSerial',
      values: [
        { label: 'Label1', values: [{ text: 'Text Value1' }] },
        {
          label: 'Label2',
          values: [
            { link: 'Link Value1', href: '"Quoted Link Value"', search_field: 'the-search-field' },
            { text: 'Text Value2' },
            { link: 'Link Value2', search_field: 'the-other-search-field' }
          ]
        }
      ]
    )
  end

  before do
    allow(view).to receive(:linked_serials).and_return(linked_serial)
    render
  end

  describe 'labels' do
    it 'has dt with label for each element in the values array' do
      expect(subject).to have_css('dt', count: 2)
      expect(subject).to have_css('dt', text: 'Label1')
      expect(subject).to have_css('dt', text: 'Label2')
    end
  end

  describe 'values' do
    it 'has a dd with a value for each element in the values array' do
      expect(subject).to have_css('dd', count: 2)
    end

    it 'renders text values as text' do
      expect(subject).to have_css('dd', text: 'Text Value1')
      expect(subject).not_to have_css('dd a', text: 'Text Value1')
    end

    it 'combined arrays of links and text properly' do
      expect(subject).to have_css('dd a', text: 'Link Value1')
      expect(subject).to have_content('Text Value2')
      expect(subject).not_to have_css('dd a', text: 'Text Value2')
      expect(subject).to have_css('dd a', text: 'Link Value2')
    end

    it 'links to the "href" key if present' do
      link1 = subject.all('a').first
      expect(link1['href']).to include 'q=%22Quoted+Link+Value%22'
    end

    it 'links to the "link" key if no "href" is present' do
      link1 = subject.all('a').last
      expect(link1['href']).to include 'q=Link+Value'
    end

    it 'includes the search_field in the url' do
      link1 = subject.all('a').last
      expect(link1['href']).to include 'search_field=the-other-search-field'
    end
  end
end
