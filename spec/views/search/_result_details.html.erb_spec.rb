# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'search/_result_details' do
  let(:description) { 'The Description' }
  let(:result) do
    SearchResult.new(
      title: 'Title',
      link: 'http://example.com',
      description: description,
      author: 'The Author',
      imprint: 'Oxford : Oxford University Press, 2013.',
      fulltext_link_html: '<a href="#">Link</a>'
    )
  end

  before do
    without_partial_double_verification do
      allow(view).to receive(:result).and_return(result)
    end

    render
  end

  it 'links to the title' do
    within 'h3' do
      expect(rendered).to have_link('Title', href: 'http://example.com')
    end
  end

  it 'renders the author' do
    expect(rendered).to have_content('The Author')
  end

  it 'renders the imprint' do
    expect(rendered).to have_content 'Oxford : Oxford University Press, 2013.'
  end

  it 'renders the description' do
    expect(rendered).to have_css('p', text: 'The Description')
  end

  it 'renders the fulltext link html' do
    within 'p' do
      expect(rendered).to have_link('Link', href: '#')
    end
  end

  context 'with a Book' do
    let(:result) do
      SearchResult.new(
        format: 'Book',
        title: 'Title',
        icon: 'notebook.svg',
        link: 'http://example.com',
        author: 'The Author',
        pub_year: '2022',
        fulltext_link_html: '<a href="#">Link</a>'
      )
    end

    it 'displays the Book format' do
      expect(rendered).to have_content('Book')
    end

    it 'displays the formatted publication year' do
      expect(rendered).to have_content('(2022)')
    end
  end

  context 'with an eBook' do
    let(:result) do
      SearchResult.new(
        format: 'eBook',
        title: 'Title',
        icon: 'notebook.svg',
        link: 'http://example.com',
        author: 'The Author',
        pub_date: '2022-06-15',
        fulltext_link_html: '<a href="#">Link</a>'
      )
    end

    it 'displays the eBook format' do
      expect(rendered).to have_content('eBook')
    end

    it 'displays the formatted publication year' do
      expect(rendered).to have_content('(2022)')
    end
  end

  context 'when journal information is present' do
    context 'with a composed title with encoded italics' do
      let(:result) do
        SearchResult.new(
          format: 'Academic Journal',
          title: 'Title',
          icon: 'notebook.svg',
          link: 'http://example.com',
          author: 'The Author',
          pub_date: '2022-06-15',
          fulltext_link_html: '<a href="#">Link</a>',
          journal: 'Journal Title',
          composed_title: "\u003Ci\u003EJournal Title\u003C/i\u003E pages 11-23"
        )
      end

      it 'displays the formatted journal title and details' do
        expect(rendered).to have_content('Journal Title pages 11-23')
      end
    end

    context 'with a composed title with a searchLink' do
      let(:result) do
        SearchResult.new(
          format: 'Academic Journal',
          title: 'Title',
          icon: 'notebook.svg',
          link: 'http://example.com',
          author: 'The Author',
          pub_date: '2022-06-15',
          fulltext_link_html: '<a href="#">Link</a>',
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
