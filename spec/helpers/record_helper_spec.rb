# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecordHelper do
  describe 'subjects' do
    let(:subjects) { [OpenStruct.new(label: 'Subjects', values: [%w(Subject1a Subject1b), %w(Subject2a Subject2b Subject2c)])] }

    describe '#linked_mods_subjects' do
      it 'should join the subject fields in a dd' do
        expect(helper.linked_mods_subjects(subjects)).to match /<dd><a href=*.*">Subject1a*.*Subject1b<\/a><\/dd>\s*<dd><a/
      end
    end

    describe 'genres' do
      let(:genres) { [OpenStruct.new(label: 'Genres', values: %w(Genre1 Genre2 Genre3))] }

      describe '#linked_mods_genres' do
        it 'should join the genre fields with a dd' do
          expect(helper.linked_mods_genres(genres)).to match /<dd><a href=*.*>Genre1*.*<\/a><\/dd>\s*<dd><a*.*Genre2<\/a><\/dd>/
        end
      end
    end
  end

  describe 'record html' do
    context 'when the record has line feeds in the string' do
      let(:html) { "some text\r\nsome other text" }

      it 'returns the string without changing the encoding' do
        expect(helper.format_record_html(html)).to eq "<p>some text\n<br />some other text</p>"
      end
    end

    context 'when the record has encoded line feeds in the string' do
      let(:html) { "some text&#13\nsome other text" }

      it 'returns the string with proper encoding' do
        expect(helper.format_record_html(html)).to eq "<p>some text\n<br />some other text</p>"
      end
    end
  end
end
