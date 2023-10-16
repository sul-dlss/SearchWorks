require 'rails_helper'

RSpec.describe ArticleHelper do
  describe '#article_search?' do
    context 'when in the ArticlesController' do
      before { expect(helper).to receive_messages(controller_name: 'articles') }

      it { expect(helper.article_search?).to be true }
    end

    context 'when not in the ArticlesController' do
      before { expect(helper).to receive_messages(controller_name: 'anything_else') }

      it { expect(helper.article_search?).to be false }
    end
  end

  context '#link_to_doi' do
    it 'renders a link by appending the value to the DOI resolver' do
      result = helper.link_to_doi(value: %w[abc])
      expect(result).to have_css('a @href', text: 'https://doi.org/abc')
      expect(result).to have_css('a', text: 'abc')
    end
    it 'renders only the first link' do
      result = helper.link_to_doi(value: %w[abc def])
      expect(result).to have_css('a', text: 'abc')
    end
    it 'renders nothing if missing' do
      result = helper.link_to_doi(value: nil)
      expect(result).to be_nil
    end
  end

  describe '#link_subjects' do
    it 'quotes the subject and does a subject search' do
      result = Capybara.string(helper.link_subjects(value: ['<searchLink fieldCode="SU" term="ABC">ABC</searchLink><br/><searchLink fieldCode="SU" term="123">123</searchLink>']))
      expect(result).to have_link 'ABC', href: /\?q=ABC&search_field=subject/
      expect(result).to have_link '123', href: /\?q=123&search_field=subject/
    end
  end

  context 'authors' do
    let(:authors) { %w[John\ Doe,\ Author Doe,\ Jane Fred\ Doe] }
    let(:affiliations) { ["<relatesTo>1</relatesTo>Institute A<br /><relatesTo>2</relatesTo>Institute B<br /><relatesTo>3</relatesTo>Institute C"] }

    context '#link_authors' do
      subject(:result) { Capybara.string(helper.link_authors(value: authors)) }

      it 'includes a search link for each author' do
        expect(result).to have_link 'John Doe', href: '/articles?q=%22John+Doe%22&search_field=author'
        expect(result).to have_link 'Doe, Jane', href: '/articles?q=%22Doe%2C+Jane%22&search_field=author'
        expect(result).to have_link 'Fred Doe', href: '/articles?q=%22Fred+Doe%22&search_field=author'
        expect(result).to have_content 'John Doe, Author, Doe, Jane, and Fred Doe'
      end
    end

    context '#strip_author_relators' do
      subject(:result) { Capybara.string(helper.strip_author_relators(value: authors)) }

      it 'removes relator terms' do
        expect(result).to have_content 'John Doe, Doe, Jane, and Fred Doe'
      end
      it 'has no links' do
        expect(result).not_to have_link
      end
    end

    context '#clean_affiliations' do
      let(:result) { helper.clean_affiliations(value: affiliations) }

      it 'removes relatesTo tags and content' do
        expect(result).not_to have_content('1')
        expect(result).to have_content('Institute A')
      end
    end
  end

  context '#render_text_from_html' do
    it 'returns only text from HTML' do
      result = helper.render_text_from_html(%w[ab<c>d</c>])
      expect(result).to eq %w[ab d]
    end

    it 'handles single values the same as arrays' do
      result = helper.render_text_from_html('ab<c>d</c>')
      expect(result).to eq %w[ab d]
    end

    it 'returns an empty array if missing' do
      result = helper.render_text_from_html(nil)
      expect(result).to eq []
    end
  end

  context '#mark_html_safe' do
    it 'preserves HTML entities to render' do
      result = helper.mark_html_safe(value: Array.wrap('This &amp; That'))
      expect(result).to eq 'This &amp; That'
    end
    it 'preserves HTML elements to render' do
      result = helper.mark_html_safe(value: Array.wrap('<i>This Journal</i>, 10(1)'))
      expect(result).to eq '<i>This Journal</i>, 10(1)'
    end
    it 'handles multiple values' do
      result = helper.mark_html_safe(value: %w[This That])
      expect(result).to eq 'This and That'
      result = helper.mark_html_safe(value: %w[This That The\ Other])
      expect(result).to eq 'This, That, and The Other'
    end
    it 'handles multiple values with separators' do
      result = helper.mark_html_safe(value: %w[This That], config: { separator_options: { two_words_connector: '<br/>' } })
      expect(result).to eq 'This<br/>That'
    end
  end

  context '#sanitize_fulltext' do
    it 'preserves HTML entities to render' do
      result = helper.mark_html_safe(value: Array.wrap('This &amp; That'))
      expect(result).to eq 'This &amp; That'
    end

    it 'preserves HTML elements to render' do
      result = helper.sanitize_fulltext(value: Array.wrap('<p>This Journal</p>, 10(1)'))
      expect(result).to eq '<p>This Journal</p>, 10(1)'
    end

    it 'removes non-HTML EDS tags' do
      result = helper.sanitize_fulltext(value: Array.wrap('<anid>09dfa;</anid><p>This Journal</p>, 10(1)'))
      expect(result).to eq '<p>This Journal</p>, 10(1)'
    end
  end

  describe '#remove_html_from_document_field' do
    it 'returns to_sentance joined text splitting on and stripping HTML' do
      result = remove_html_from_document_field(value: Array.wrap('Thing1<br/>Thing2<br/>Thing3'))

      expect(result).to eq 'Thing1, Thing2, and Thing3'
    end
  end

  context '#italicize_composed_title' do
    let(:result) { helper.italicize_composed_title(value: Array.wrap(title)) }

    context 'no title' do
      let(:title) { nil }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end

    context 'blank title' do
      let(:title) { '  ' }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end

    context 'already marked up' do
      let(:title) { '<i>This Journal</i>. 10(1)' }

      it 'just returns as-is but marked HTML safe' do
        expect(result).to eq title
        expect(result).to be_html_safe
      end
    end

    context 'already marked up with anchor' do
      let(:title) { '<searchLink fieldCode="FT">This Journal</searchLink>. 10(1)' }

      it 'just returns as-is' do
        expect(result).to eq title
        expect(result).to be_html_safe
      end
    end

    context 'even marked up multiple times' do
      let(:title) { '<searchLink fieldCode="FT">This Journal</searchLink>. <i>10</i>(1)' }

      it 'just returns as-is' do
        expect(result).to eq title
        expect(result).to be_html_safe
      end
    end

    context 'no markup' do
      let(:title) { 'This Journal. 10(1)' }

      it 'italicizes first phrase' do
        expect(result).to eq '<i>This Journal</i>. 10(1)'
        expect(result).to be_html_safe
      end
    end

    context 'no markup but weird punctuation' do
      context 'with []' do
        let(:title) { 'This Journal [Alternate Name]. 10(1)' }

        it 'italicizes first phrase' do
          expect(result).to eq '<i>This Journal </i>[Alternate Name]. 10(1)'
          expect(result).to be_html_safe
        end
      end

      context 'with commas' do
        let(:title) { 'Agriculture, ecosystems & environment. 10(1)' }

        it 'fails to do a good job' do
          expect(result).to eq '<i>Agriculture</i>, ecosystems & environment. 10(1)'
          expect(result).to be_html_safe
        end
      end

      context 'with &' do
        let(:title) { 'Ecosystems & environment. 10(1)' }

        it 'fails to do a good job' do
          expect(result).to eq '<i>Ecosystems </i>& environment. 10(1)'
          expect(result).to be_html_safe
        end
      end
    end
  end

  describe '#sanitize_research_starter' do
    subject(:result) { view.sanitize_research_starter(value: [value], document:) }

    let(:document) { SolrDocument.new('eds_database_id' => 'xyz') }

    context '#transform_research_starter_text' do
      let(:value) { 'abc' }

      context 'removes anid and title' do
        let(:value) { '<anid>abc</anid><title>123</title>' }

        it do
          expect(result).to eq ''
        end
      end

      context 'rewrites EDS tags with regular HTML tags' do
        let(:value) { '<bold/><emph/><ulist><item><subs/><sups/></item></ulist>' }

        it do
          expect(result).to eq "<b></b><i></i><ul><li>\n<sub></sub><sup></sup>\n</li></ul>"
        end
      end

      context 'rewrites EDS eplinks' do
        let(:value) { '<eplink linkkey="abc123">def456</eplink>' }
        let(:document) { { 'eds_html_fulltext' => value, 'eds_database_id' => 'xyz' } }

        it do
          expect(result).to eq '<a href="/articles/xyz__abc123">def456</a>'
        end
      end

      context 'converts images to figures with captions' do
        let(:value) { '<img src="abc.jpg" title="def"/>' }

        it do
          html = Capybara.string(result)
          expect(html).to have_css('.research-starter-figure')
          expect(html).to have_css('img[src="abc.jpg"]')
          expect(html).to have_css('span', text: 'def')
        end
      end

      context 'removes any unknown elements' do
        let(:value) { '<unknown/>' }

        it do
          expect(result).to eq ''
        end
      end

      context 'preserves desired element' do
        %w[p a b i ul li div span sub sup].each do |tag|
          context tag do
            let(:value) { "<#{tag}>abc</#{tag}>" }

            it do
              expect(result).to eq(value).and be_html_safe
            end
          end
        end
      end
    end
  end
end
