# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LinkedSerials do
  include MarcMetadataFixtures
  subject { described_class.new(SolrDocument.new(marc_json_struct: marc)) }

  describe 'labels' do
    context '780s' do
      let(:marc) { title_change_fixture }

      it 'returns a value for each 780' do
        expect(subject.values.length).to eq 2
      end

      it 'has a label based on the indicator2' do
        expect(subject.values.first[:label]).to eq 'Continues'
        expect(subject.values.last[:label]).to eq 'Absorbed in part by'
      end
    end

    context '785' do
      let(:marc) { merged_with_serial_fixture }

      it 'returns the "Merged with" label for the first merged with 785' do
        expect(subject.values.first[:label]).to eq 'Merged with'
      end

      it 'returns the "and with" label middle merged with 785s' do
        expect(subject.values[1][:label]).to eq 'and with'
      end

      it 'returns the "Merged with" label for the last merged with 785' do
        expect(subject.values.last[:label]).to eq 'to form'
      end
    end

    context 'other serials' do
      let(:marc) { main_entry_and_title_serial_fixture }

      it 'has a field based label' do
        expect(subject.values.last[:label]).to eq 'Constituent unit'
      end
    end
  end

  describe 'values' do
    context 'when main entry ($a) is present' do
      context 'when title data ($s or $t) is present' do
        let(:marc) { main_entry_and_title_serial_fixture }

        it 'included a hash that combines the main entry with the title and indicated author_title search' do
          expect(subject.values.first[:values].first[:link]).to eq 'Serial Main Entry Serial Uniform Title'
          expect(subject.values.first[:values].first[:href]).to eq '"Serial Main Entry Serial Uniform Title"'
          expect(subject.values.first[:values].first[:search_field]).to eq 'author_title'
        end
      end

      context 'when no title data is present' do
        let(:marc) { merged_with_serial_fixture }

        it 'links the main entry to an all field search' do
          expect(subject.values.first[:values].first[:link]).to eq 'Serial Main Entry1'
          expect(subject.values.first[:values].first[:search_field]).to eq 'search'
        end
      end

      context 'for vernacular' do
        let(:marc) { vernacular_serial_fixture }

        it 'labels vernacular fields correctly' do
          expect(subject.values.length).to eq 2
          expect(subject.values.last[:label]).to eq 'Continues'
          expect(subject.values.last[:values].first[:link]).to eq 'Vernacular Serial Uniform Title'
        end
      end
    end

    context 'for ISSN number ($x)' do
      let(:marc) { main_entry_and_title_serial_fixture_with_issn }

      it 'has an ISSN prefix' do
        expect(subject.values.last[:values][2][:text]).to eq 'ISSN'
      end

      it 'links to the isbn_search search field' do
        expect(subject.values.last[:values][3][:search_field]).to eq 'isbn_search'
      end
    end

    context 'for ISBN number ($z)' do
      let(:marc) { main_entry_and_title_serial_fixture }

      it 'links to the isbn_search search field' do
        expect(subject.values.last[:values][2][:search_field]).to eq 'isbn_search'
      end
    end

    describe 'title data' do
      context 'when main entry is present' do
        let(:marc) { main_entry_and_title_serial_fixture }

        it 'prefers uniform title ($s) over title (t)' do
          expect(subject.values.first[:values].first[:link]).to include 'Serial Uniform Title'
          expect(subject.values.first[:values].first[:link]).not_to include 'Serial Title'
        end
      end

      context 'when only title data is present' do
        let(:marc) { only_title_serial_fixture }

        it 'prefers uniform title ($s) over title (t) and does not duplicate data' do
          expect(subject.values.first[:values].length).to eq 2
          expect(subject.values.first[:values].first).to eq(text: 'Other Data:')
          expect(subject.values.first[:values].last[:link]).to eq 'Serial Uniform Title'
        end

        it 'does a title search' do
          expect(subject.values.first[:values].last[:search_field]).to eq 'search_title'
        end
      end
    end

    context 'other subfields' do
      let(:marc) { main_entry_and_title_serial_fixture }

      it 'are described as text' do
        expect(subject.values.last[:values].first).to eq(text: 'Some text:')
      end
    end
  end
end
