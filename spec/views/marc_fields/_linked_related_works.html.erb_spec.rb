require 'rails_helper'

RSpec.describe 'marc_fields/_linked_related_works' do
  include MarcMetadataFixtures
  let(:document) { SolrDocument.new(marc_json_struct: linked_related_works_fixture) }

  before do
    allow(view).to receive_messages(linked_related_works: LinkedRelatedWorks.new(document))
    render
  end

  context 'base' do
    it 'renders the label in a dt' do
      expect(rendered).to have_css('dt', text: 'Related Work')
    end

    it 'renders 5 related works in dd elements' do
      expect(rendered).to have_css('dd', count: 5)
    end

    it 'renders pre_text' do
      text = /i1_subfield_text:\s+i2_subfield_text:/ # in order
      expect(rendered).to have_css('dd', text:)
      expect(rendered).not_to have_css('dd a', text:)
    end

    it 'renders link' do
      %w[a d f k l h m n o p r s t].each do |subfield_code|
        expect(rendered).to have_css('dd:nth-of-type(1) a', text: "#{subfield_code}_subfield_text")
      end
    end

    it 'renders search' do
      expect(rendered).to have_css('dd:nth-of-type(1) a @href', text: 'q=')
      expect(rendered).not_to have_css('dd:nth-of-type(1) a @href', text: 'q=%22') # not quoted

      expect(rendered).to have_css('dd:nth-of-type(1) a @href', text: 'search_field=search_title')

      %w[a d f k l m n o p r s t].each do |subfield_code|
        expect(rendered).to have_css('dd:nth-of-type(1) a @href', text: "#{subfield_code}_subfield_text")
      end
      expect(rendered).not_to have_css('dd:nth-of-type(1) a @href', text: 'h_subfield_text') # inner text
    end

    it 'renders post_text' do
      text = 'x1_subfield_text. x2_subfield_text. 3_subfield_text' # in order
      expect(rendered).to have_css('dd:nth-of-type(1)', text:)
      expect(rendered).not_to have_css('dd:nth-of-type(1) a', text:)
      %w[0 5 8].each do |subfield_code|
        expect(rendered).not_to have_css('dd:nth-of-type(1) a', text: "#{subfield_code}_subfield_text")
      end
    end

    it 'renders 700 fields' do
      expect(rendered).to have_css('dd:nth-of-type(2) a', text: '700_a_subfield_text')
    end

    it 'renders 710 fields' do
      expect(rendered).to have_css('dd:nth-of-type(3) a', text: '710_with_ind2_1')
      expect(rendered).not_to have_css('dd:nth-of-type(3) a', text: '710_with_ind2_2')
    end

    it 'renders 711 fields' do
      expect(rendered).to have_css('dd:nth-of-type(4) a', text: '711_a_subfield_text')
    end

    it 'renders 720 fields' do
      expect(rendered).to have_css('dd:nth-of-type(5) a', text: '720_a_subfield_text')
    end
  end

  context 'contributed works' do
    let(:document) { SolrDocument.new(marc_json_struct: contributed_works_fixture) }

    it 'renders the only field that matches a related work criteria' do
      expect(rendered).to have_css('dd', count: 1)
      expect(rendered).to have_css('dd a', text: '700 with t 700 $e Title. sub m after .')
    end
  end
end
