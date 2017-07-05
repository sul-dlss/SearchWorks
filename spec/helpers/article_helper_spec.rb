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

  context '#render_text_from_html' do
    it 'renders only text from HTML' do
      result = helper.render_text_from_html(value: %w[ab<c>d</c>])
      expect(result).to eq 'abd'
    end
    it 'renders element seperated text from HTML with spaces' do
      result = helper.render_text_from_html(value: %w[ab<c>d</c><f>g</f>h], config: { seperator: ' '})
      expect(result).to eq 'ab d g h'
    end
    it 'renders space seperated text from HTML' do
      result = helper.render_text_from_html(value: %w[ab<c>d</c>\ e<f>g</f>h])
      expect(result).to eq 'abd egh'
    end
    it 'renders only the first value' do
      result = helper.render_text_from_html(value: %w[ab<c>d</c> more text])
      expect(result).to eq 'abd'
    end
    it 'renders nothing if missing' do
      result = helper.render_text_from_html(value: nil)
      expect(result).to be_nil
    end
  end
end
