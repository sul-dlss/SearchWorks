require 'rails_helper'

RSpec.describe EdsSubjects do
  let(:document) do
    SolrDocument.new(
      'eds_subjects' => '<searchLink fieldCode="SH" term="abc &amp; def">abc &amp; def</searchLink>' \
                        '<br>' \
                        '<searchLink fieldCode="SU" term="xyz">xyz</searchLink>' \
                        '<br/>' \
                        '<searchLink fieldCode="DE" term="zyx">zyx</searchLink>' \
                        '<br />' \
                        '<searchLink fieldCode="KW" term="abc">abc</searchLink>',
      'eds_subjects_person' => %w[Person1 Person2],
      'eds_subjects_geographic' => %w[Paris France],
      'eds_author_supplied_keywords' => '<searchLink fieldcode="KW" term="%22income+inequality%22">income inequality</searchLink>' \
                                        '<br>' \
                                        '<searchLink fieldcode="KW" term="%22taxation%22">taxation</searchLink>'
    )
  end

  context '#eds_subjects' do
    it 'returns an array of Subjects parsed from the XML' do
      expect(document.eds_subjects).to be_present
      expect(document.eds_subjects.length).to eq 4

      document.eds_subjects.each do |subj|
        expect(subj).to be_a EdsSubjects::Subject
      end
    end

    it 'correctly handles HTML entities' do
      subj = document.eds_subjects[0]
      expect(subj.to_s).to eq 'abc & def'
    end

    it 'uses the anchor for the subject' do
      subj = document.eds_subjects[1]
      expect(subj.to_s).to eq 'xyz'
      subj = document.eds_subjects[2]
      expect(subj.to_s).to eq 'zyx'
      subj = document.eds_subjects[3]
      expect(subj.to_s).to eq 'abc'
    end

    it 'converts searchLinks to hyperlinks with correct search_field' do
      subj = document.eds_subjects[0]
      expect(subj.to_html).to eq '<a href="/articles?q=%22abc+%26+def%22&search_field=subject_heading">abc &amp; def</a>'
      subj = document.eds_subjects[1]
      expect(subj.to_html).to eq '<a href="/articles?q=xyz&search_field=subject">xyz</a>'
      subj = document.eds_subjects[2]
      expect(subj.to_html).to eq '<a href="/articles?q=zyx&search_field=descriptor">zyx</a>'
      subj = document.eds_subjects[3]
      expect(subj.to_html).to eq '<a href="/articles?q=abc&search_field=keyword">abc</a>'
    end
  end

  context '#eds_subjects_person' do
    it 'returns an array of Subjects parsed from the vanilla array' do
      expect(document.eds_subjects_person).to be_present
      expect(document.eds_subjects_person.length).to eq 2

      document.eds_subjects_person.each do |subj|
        expect(subj).to be_a EdsSubjects::Subject
      end
    end

    it 'finds the right subjects' do
      expect(document.eds_subjects_person[0].to_s).to eq 'Person1'
      expect(document.eds_subjects_person[1].to_s).to eq 'Person2'
    end
  end

  context '#eds_subjects_geographic' do
    it 'returns an array of Subjects parsed from the vanilla array' do
      expect(document.eds_subjects_geographic).to be_present
      expect(document.eds_subjects_geographic.length).to eq 2

      document.eds_subjects_geographic.each do |subj|
        expect(subj).to be_a EdsSubjects::Subject
      end
    end

    it 'finds the right subjects' do
      expect(document.eds_subjects_geographic[0].to_s).to eq 'Paris'
      expect(document.eds_subjects_geographic[1].to_s).to eq 'France'
    end
  end

  context '#eds_author_supplied_keywords' do
    it 'returns an array of Subjects parsed from the vanilla array' do
      expect(document.eds_author_supplied_keywords).to be_present
      expect(document.eds_author_supplied_keywords.length).to eq 2

      document.eds_author_supplied_keywords.each do |subj|
        expect(subj).to be_a EdsSubjects::Subject
      end
    end

    it 'finds the right subjects' do
      expect(document.eds_author_supplied_keywords[0].to_s).to eq 'income inequality'
      expect(document.eds_author_supplied_keywords[1].to_s).to eq 'taxation'
    end

    it 'converts searchLinks to hyperlinks with correct search_field' do
      subj = document.eds_author_supplied_keywords[0]
      expect(subj.to_html).to eq '<a href="/articles?q=%22income+inequality%22&search_field=keyword">income inequality</a>'
      subj = document.eds_author_supplied_keywords[1]
      expect(subj.to_html).to eq '<a href="/articles?q=taxation&search_field=keyword">taxation</a>'
    end
  end

  pending 'sometimes EDS uses semi-colons rather than <br> as delimiters'
end
