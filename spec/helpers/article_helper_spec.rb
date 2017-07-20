require 'spec_helper'

RSpec.describe ArticleHelper do
  describe '#article_search?' do
    context 'when in the ArticlesController' do
      before { expect(helper).to receive_messages(controller_name: 'article') }

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
      result = Capybara.string(helper.link_subjects(value: %w[ABC 123]))
      expect(result).to have_link 'ABC', href: /\?q=DE\+%22ABC%22/
      expect(result).to have_link '123', href: /\?q=DE\+%22123%22/
    end

    it 'handles html (via render_text_from_html)' do
      result = Capybara.string(helper.link_subjects(value: %w[<p>ABC</p><p>123</p>]))
      expect(result).to have_link 'ABC', href: /\?q=DE\+%22ABC%22/
      expect(result).to have_link '123', href: /\?q=DE\+%22123%22/
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
end
