require 'spec_helper'

describe RecordHelper do
  let(:empty_field) { OpenStruct.new(label: 'test', values: ['']) }
  describe 'display_content_field' do
    let(:values) { ['guitar (1)', 'solo cowbell, trombone (2)'] }
    let(:content) { OpenStruct.new(label: 'Instrumentation', values: values) }
    it 'should return dt with label and dd with values' do
      expect(helper.display_content_field(content)).to have_css('dt', text: 'Instrumentation')
      expect(helper.display_content_field(content)).to have_css('dd', count: 2)
    end
  end
  describe 'display_content_label' do
    it 'should return correct dt' do
      expect(helper.display_content_label('test')).to have_css('dt', text: 'test')
    end
  end

  describe 'display_content_values' do
    let(:values) { ['guitar (1)', 'solo cowbell, trombone (2)'] }
    it 'should return dds of values' do
      expect(helper.display_content_values(values)).to have_css('dd', count: 2)
      expect(helper.display_content_values(values)).to have_css('dd', text: 'guitar (1)')
      expect(helper.display_content_values(values)).to have_css('dd', text: 'solo cowbell, trombone (2)')
    end
  end

  describe 'mods_display_label' do
    it 'should return correct label' do
      expect(helper.mods_display_label('test:')).to_not have_content ':'
      expect(helper.mods_display_label('test:')).to have_css('dt', text: 'test')
    end
  end

  describe 'mods_display_content' do
    it 'should return correct content' do
      expect(helper.mods_display_content('hello, there')).to have_css('dd', text: 'hello, there')
    end
    it 'should return multiple dd elements when a multi-element array is passed' do
      expect(helper.mods_display_content(%w(hello there))).to have_css('dd', count: 2)
    end
    it 'should handle nil values correctly' do
      expect(helper.mods_display_content(['something', nil])).to have_css('dd', count: 1)
    end
  end

  describe 'mods_record_field' do
    let(:mods_field) { OpenStruct.new(label: 'test', values: ['hello, there']) }
    let(:url_field) { OpenStruct.new(label: 'test', values: ['https://library.stanford.edu']) }
    let(:multi_values) { double(label: 'test', values: %w(123 321)) }
    it 'should return correct content' do
      expect(helper.mods_record_field(mods_field)).to have_css('dt', text: 'test')
      expect(helper.mods_record_field(mods_field)).to have_css('dd', text: 'hello, there')
    end
    it 'should link fields with URLs' do
      expect(mods_record_field(url_field)).to have_css("a[href='https://library.stanford.edu']", text: 'https://library.stanford.edu')
    end
    it 'should not print empty labels' do
      expect(helper.mods_record_field(empty_field)).to_not be_present
    end
    it 'should join values with a <dd> by default' do
      expect(helper.mods_record_field(multi_values)).to have_css('dd', count: 2)
    end
    it 'should join values with a supplied delimiter' do
      expect(helper.mods_record_field(multi_values, 'DELIM')).to have_css('dd', count: 1)
      expect(helper.mods_record_field(multi_values, 'DELIM')).to have_css('dd', text: '123DELIM321')
    end
  end
  describe 'names' do
    let(:name_field) do
      OpenStruct.new(
        label: 'Contributor',
        values: [
          OpenStruct.new(name: 'Winefrey, Oprah', roles: %w(Host Producer)),
          OpenStruct.new(name: 'Kittenz, Emergency')
        ]
      )
    end
    describe '#mods_name_field' do
      it 'should join the label and values' do
        name = mods_name_field(name_field)
        expect(name).to match /<dt>Contributor<\/dt>/
        expect(name).to match /<dd><a href.*<\/dd>/
      end
      it 'should not print empty labels' do
        expect(mods_name_field(empty_field)).to_not be_present
      end
    end

    describe '#mods_display_name' do
      let(:name) { mods_display_name(name_field.values) }
      it 'should link to the name' do
        expect(name).to match /<a href=.*%22Winefrey%2C\+Oprah%22.*>Winefrey, Oprah<\/a>/
        expect(name).to match /<a href=.*%22Kittenz%2C\+Emergency%22.*>Kittenz, Emergency<\/a>/
      end
      it 'should link to an author search' do
        expect(name).to match /<a href.*search_field=search_author.*>/
      end
    end

    describe '#sanitize_mods_name_label' do
      it 'removes a ":" at the end of label if present' do
        expect(sanitize_mods_name_label('Test String:')).to eq 'Test String'
        expect(sanitize_mods_name_label('Test String')).to eq 'Test String'
      end
    end
  end
  describe 'subjects' do
    let(:subjects) { [OpenStruct.new(label: 'Subjects', values: [%w(Subject1a Subject1b), %w(Subject2a Subject2b Subject2c)])] }
    let(:name_subjects) { [OpenStruct.new(label: 'Subjects', values: [OpenStruct.new(name: 'Person Name', roles: %w(Role1 Role2))])] }
    let(:genres) { [OpenStruct.new(label: 'Genres', values: %w(Genre1 Genre2 Genre3))] }
    describe '#mods_subject_field' do
      it 'should join the subject fields in a dd' do
        expect(mods_subject_field(subjects)).to match /<dd><a href=*.*\">Subject1a*.*Subject1b<\/a><\/dd><dd><a/
      end
      it "should join the individual subjects with a '>'" do
        expect(mods_subject_field(subjects)).to match /Subject2b<\/a> &gt; <a href/
      end
      it 'should not print empty labels' do
        expect(mods_subject_field(empty_field)).to_not be_present
      end
    end
    describe '#mods_genre_field' do
      it 'should join the genre fields with a dd' do
        expect(mods_genre_field(genres)).to match /<dd><a href=*.*>Genre1*.*<\/a><\/dd><dd><a*.*Genre2<\/a><\/dd>/
      end
      it 'should not print empty labels' do
        expect(mods_genre_field(empty_field)).to_not be_present
      end
    end
    describe '#link_mods_subjects' do
      let(:linked_subjects) { link_mods_subjects(subjects.first.values.last) }
      it 'should return all subjects' do
        expect(linked_subjects.length).to eq 3
      end
      it 'should link to the subject hierarchically' do
        expect(linked_subjects[0]).to match /^<a href=.*q=%22Subject2a%22.*>Subject2a<\/a>$/
        expect(linked_subjects[1]).to match /^<a href=.*q=%22Subject2a\+Subject2b%22.*>Subject2b<\/a>$/
        expect(linked_subjects[2]).to match /^<a href=.*q=%22Subject2a\+Subject2b\+Subject2c%22.*>Subject2c<\/a>$/
      end
      it 'should link to subject terms search field' do
        linked_subjects.each do |subject|
          expect(subject).to match /search_field=subject_terms/
        end
      end
    end
    describe '#link_mods_genres' do
      let(:linked_genres) { link_mods_genres(genres.first.values.last) }
      it 'should return correct link' do
        expect(linked_genres).to match /<a href=*.*Genre3*.*<\/a>/
      end
      it 'should link to subject terms search field' do
        expect(linked_genres).to match /search_field=subject_terms/
      end
    end
    describe '#link_to_mods_subject' do
      it 'should handle subjects that behave like names' do
        name_subject = link_to_mods_subject(name_subjects.first.values.first, [])
        expect(name_subject).to match /<a href=.*%22Person\+Name%22.*>Person Name<\/a> \(Role1, Role2\)/
      end
    end
  end
  describe '#link_urls_and_email' do
    let(:url) { 'This is a field that contains an https://library.stanford.edu URL' }
    let(:email) { 'This is a field that contains an email@email.com address' }
    it 'should link URLs' do
      expect(link_urls_and_email(url)).to eq "This is a field that contains an <a href='https://library.stanford.edu'>https://library.stanford.edu</a> URL"
    end
    it 'should link email addresses' do
      expect(link_urls_and_email(email)).to eq "This is a field that contains an <a href='mailto:email@email.com'>email@email.com</a> address"
    end
  end
end
