# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'marc_fields/_linked_author' do
  include MarcMetadataFixtures
  let(:document) { SolrDocument.new(marc_json_struct: send(:"linked_author_#{target}_fixture")) }

  before do
    allow(view).to receive_messages(linked_author: LinkedAuthor.new(document, target))
    render
  end

  context 'Creator' do
    let(:document) { SolrDocument.new(author_struct: [{ target => [{ link: 'Dodaro, Gene L.', search: 'Dodaro, Gene L.', post_text: 'author. Author' }] }]) }
    let(:target) { :creator }

    it 'renders the label in a dt' do
      expect(rendered).to have_css('dt', text: 'Author/Creator')
    end

    it 'renders author in a dd' do
      expect(rendered).to have_css('dd', count: 1)
    end

    it 'renders link, search, and post_text correctly' do
      expect(rendered).to have_css('dd a', text: 'Dodaro, Gene L.')
      expect(rendered).to have_css('dd a @href', text: /q=%22Dodaro%2C\+Gene\+L\.%22/)
      expect(rendered).to have_css('dd a @href', text: /search_field=search_author/)
      expect(rendered).to have_no_css('dd a @href', text: /author\./)
      expect(rendered).to have_no_css('dd a @href', text: /\sAuthor/)
    end

    it 'included the extra text after the link' do
      expect(rendered).to have_css('dd', text: 'author. Author')
    end
  end

  context 'Corporate Author' do
    let(:document) { SolrDocument.new(author_struct: [{ target => [{ link: 'Ecuador. Procuraduría General del Estado, A Title', search: 'Ecuador. Procuraduría General del Estado,', post_text: 'author, issuing body. Art copyist' }] }]) }
    let(:target) { :corporate_author }

    it 'renders the label in a dt' do
      expect(rendered).to have_css('dt', text: 'Corporate Author')
    end

    it 'renders author in a dd' do
      expect(rendered).to have_css('dd', count: 1)
    end

    it 'renders link, search, and post_text correctly' do
      expect(rendered).to have_css('dd a', text: 'Ecuador. Procuraduría General del Estado, A Title')
      expect(rendered).to have_css('dd a @href', text: /q=%22Ecuador.\+Procuradur%C3%ADa\+General\+del\+Estado%2C%22/)
      expect(rendered).to have_css('dd a @href', text: /search_field=search_author/)
      expect(rendered).to have_no_css('dd a @href', text: /A Title/)
      expect(rendered).to have_no_css('dd a @href', text: /issuing body/)
    end

    it 'included the extra text after the link' do
      expect(rendered).to have_css('dd', text: 'author, issuing body. Art copyist')
    end
  end

  context 'Meeting (with venacular)' do
    let(:document) do
      SolrDocument.new(author_struct: [
        {
          target => [
            {
              link: 'Technical Workshop on Organic Agriculture (1st : 2010 : Ogbomoso, Nigeria) A title', search: 'Technical Workshop on Organic Agriculture (1st : 2010 : Ogbomoso, Nigeria)', post_text: 'creator. Other',
              vern: { link: 'Vernacular Title Vernacular Uniform Title', search: 'Vernacular Uniform Title' }
            }
          ]
        }
      ])
    end
    let(:target) { :meeting }

    it 'renders the label in a dt' do
      expect(rendered).to have_css('dt', text: 'Meeting')
    end

    it 'renders author and a venacular in dd' do
      expect(rendered).to have_css('dd', count: 2)
    end

    it 'renders link, search, and post_text correctly' do
      expect(rendered).to have_css('dd a', text: 'Technical Workshop on Organic Agriculture (1st : 2010 : Ogbomoso, Nigeria) A title')
      expect(rendered).to have_css('dd a', text: 'Vernacular Title Vernacular Uniform Title')
      expect(rendered).to have_css('dd a @href', text: /q=%22Technical\+Workshop\+on\+Organic\+Agriculture\+%281st\+%3A\+2010\+%3A\+Ogbomoso%2C\+Nigeria%29%22/)
      expect(rendered).to have_css('dd a @href', text: /q=%22Vernacular\+Uniform\+Title%22/)
      expect(rendered).to have_css('dd a @href', text: /search_field=search_author/)
      expect(rendered).to have_no_css('dd a @href', text: /A title/)
      expect(rendered).to have_no_css('dd a @href', text: /creator/)
    end

    it 'included the extra text after the link' do
      expect(rendered).to have_css('dd', text: 'creator. ')
    end
  end
end
