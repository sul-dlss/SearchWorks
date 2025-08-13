# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'article_results/_article_result' do
  before do
    render 'article_results/article_result', article_result:
  end

  context 'with an eBook' do
    let(:article_result) do
      ArticleResult.new(
        format: 'eBook',
        title: 'Title',
        link: 'http://example.com',
        author: 'The Author',
        pub_date: '2022-06-15',
        resource_links: [
          { href: '#', link_text: 'Link' }
        ]
      )
    end

    it 'displays the eBook format' do
      expect(rendered).to have_content('eBook')
    end

    it 'displays the formatted publication year' do
      expect(rendered).to have_content('(2022)')
    end

    it 'renders the fulltext link html' do
      within 'p' do
        expect(rendered).to have_link('Link', href: '#')
      end
    end
  end

  context 'when journal information is present' do
    context 'with a composed title with encoded italics' do
      let(:article_result) do
        ArticleResult.new(
          format: 'Academic Journal',
          title: 'Title',
          link: 'http://example.com',
          author: 'The Author',
          pub_date: '2022-06-15',
          resource_links: [
            { href: '#', link_text: 'Link' }
          ],
          journal: 'Journal Title',
          composed_title: "\u003Ci\u003EJournal Title\u003C/i\u003E pages 11-23"
        )
      end

      it 'displays the formatted journal title and details' do
        expect(rendered).to have_content('Journal Title pages 11-23')
      end
    end

    context 'with a composed title with a searchLink' do
      let(:article_result) do
        ArticleResult.new(
          format: 'Academic Journal',
          title: 'Title',
          link: 'http://example.com',
          author: 'The Author',
          pub_date: '2022-06-15',
          resource_links: [
            { href: '#', link_text: 'Link' }
          ],
          journal: 'Journal Title',
          composed_title: "\u003CsearchLink fieldcode=\"JN\" term=\"%22EAST+BAY+TIMES%22\"\u003EEAST BAY TIMES\u003C/searchLink\u003E pages 11-23"
        )
      end

      it 'displays the formatted journal title and details' do
        expect(rendered).to have_content('Journal Title pages 11-23')
      end
    end
  end
end
