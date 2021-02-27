require 'spec_helper'

describe RecordHelper do
  include ModsDisplay::Helpers::RecordHelper
  describe 'subjects' do
    let(:subjects) { [OpenStruct.new(label: 'Subjects', values: [%w(Subject1a Subject1b), %w(Subject2a Subject2b Subject2c)])] }

    describe '#linked_mods_subjects' do
      it 'should join the subject fields in a dd' do
        expect(linked_mods_subjects(subjects)).to match /<dd><a href=*.*">Subject1a*.*Subject1b<\/a><\/dd><dd><a/
      end
    end

    describe 'genres' do
      let(:genres) { [OpenStruct.new(label: 'Genres', values: %w(Genre1 Genre2 Genre3))] }

      describe '#linked_mods_genres' do
        it 'should join the genre fields with a dd' do
          expect(linked_mods_genres(genres)).to match /<dd><a href=*.*>Genre1*.*<\/a><\/dd><dd><a*.*Genre2<\/a><\/dd>/
        end
      end
    end
  end
end
