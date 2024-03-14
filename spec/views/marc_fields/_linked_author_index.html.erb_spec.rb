# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'marc_fields/_linked_author_index' do
  include MarcMetadataFixtures

  before do
    allow(view).to receive_messages(linked_author: LinkedAuthor.new(document, target))
    render
  end

  context 'Creator' do
    let(:document) { SolrDocument.new(author_struct: [{ target => [{ link: 'Dodaro, Gene L.', search: 'Dodaro, Gene L.', post_text: 'author. Author' }] }]) }
    let(:target) { :creator }

    it 'does not render the label' do
      expect(rendered).not_to match(/Author\/Creator/)
    end

    it 'renders link, search, and post_text correctly' do
      expect(rendered).to have_css('li a', text: 'Dodaro, Gene L.')
      expect(rendered).to have_css('li a @href', text: /q=%22Dodaro%2C\+Gene\+L\.%22/)
      expect(rendered).to have_css('li a @href', text: /search_field=search_author/)
      expect(rendered).to have_no_css('li a @href', text: /author\./)
      expect(rendered).to have_no_css('li a @href', text: /\sAuthor/)
    end

    it 'included the extra text after the link' do
      expect(rendered).to match(/author\. Author/)
    end
  end

  context 'Corporate Author' do
    let(:document) { SolrDocument.new(author_struct: [{ target => [{ link: 'Ecuador. Procuraduría General del Estado, A Title', search: 'Ecuador. Procuraduría General del Estado,', post_text: 'author, issuing body. Art copyist' }] }]) }
    let(:target) { :corporate_author }

    it 'does not render the label' do
      expect(rendered).not_to match(/Corporate Author/)
    end

    it 'renders link, search, and post_text correctly' do
      expect(rendered).to have_css('li a', text: 'Ecuador. Procuraduría General del Estado, A Title')
      expect(rendered).to have_css('li a @href', text: /q=%22Ecuador.\+Procuradur%C3%ADa\+General\+del\+Estado%2C%22/)
      expect(rendered).to have_css('li a @href', text: /search_field=search_author/)
      expect(rendered).to have_no_css('li a @href', text: /A Title/)
      expect(rendered).to have_no_css('li a @href', text: /issuing body/)
    end

    it 'included the extra text after the link' do
      expect(rendered).to match(/author, issuing body\. Art copyist/)
    end
  end

  context 'Meeting (with venacular)' do
    let(:document) do
      SolrDocument.new(author_struct: [
        {
          target => [
            {
              link: 'Technical Workshop on Organic Agriculture (1st : 2010 : Ogbomoso, Nigeria) A title',
              search: 'Technical Workshop on Organic Agriculture (1st : 2010 : Ogbomoso, Nigeria)',
              post_text: 'creator. Other',
              vern: { link: 'Vernacular Title Vernacular Uniform Title', search: 'Vernacular Uniform Title' }
            }
          ]
        }
      ])
    end
    let(:target) { :meeting }

    it 'does not render label' do
      expect(rendered).not_to match(/Meeting/)
    end

    it 'renders link, search, and post_text correctly' do
      expect(rendered).to have_css('li:nth-child(1) a', text: 'Technical Workshop on Organic Agriculture (1st : 2010 : Ogbomoso, Nigeria) A title')
      expect(rendered).to have_css('li:nth-child(1) a @href', text: /q=%22Technical\+Workshop\+on\+Organic\+Agriculture\+%281st\+%3A\+2010\+%3A\+Ogbomoso%2C\+Nigeria%29%22/)
      expect(rendered).to have_css('li:nth-child(1) a @href', text: /search_field=search_author/)
      expect(rendered).to have_no_css('li:nth-child(1) a @href', text: /A title/)
      expect(rendered).to have_no_css('li:nth-child(1) a @href', text: /creator/)
    end

    it 'renders the venacular correctly' do
      expect(rendered).to have_css('li:nth-child(2) a', text: 'Vernacular Title Vernacular Uniform Title')
      expect(rendered).to have_css('li:nth-child(2) a @href', text: /q=%22Vernacular\+Uniform\+Title%22/)
    end

    it 'included the extra text after the link' do
      expect(rendered).to match(/creator\. Other/)
    end
  end
end
