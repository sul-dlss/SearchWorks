# frozen_string_literal: true

require "rails_helper"

RSpec.describe MainTitleDateComponent, type: :component do
  subject(:component) { described_class.new(document:) }

  before do
    render_inline(component)
  end

  context 'with a single date' do
    let(:document) { SolrDocument.new(pub_year_ss: '1999') }

    it 'draws the date' do
      expect(page).to have_css('.main-title-date', text: '[1999]')
    end
  end

  context 'with a range' do
    let(:document) { SolrDocument.new(pub_year_ss: '1801 ... 1837') }

    it 'draws the date' do
      expect(page).to have_css('.main-title-date', text: '[1801 ... 1837]')
    end
  end

  context 'with a BC date' do
    let(:document) { SolrDocument.new(pub_year_ss: '199 B.C.') }

    it 'draws the date' do
      expect(page).to have_css('.main-title-date', text: '[199 B.C.]')
    end
  end

  context 'with an EDS document' do
    let(:document) do
      EdsDocument.new(
        {
          'RecordInfo' => {
            'BibRecord' => {
              'BibRelationships' => {
                'IsPartOfRelationships' => [
                  {
                    'BibEntity' => {
                      'Dates' => [
                        { 'Type' => 'published', 'Y' => '2017', 'M' => '01', 'D' => '01' }
                      ]
                    }
                  }
                ]
              }
            }
          }
        }
      )
    end

    it 'draws the date' do
      expect(page).to have_css('.main-title-date', text: '[2017]')
    end
  end
end
