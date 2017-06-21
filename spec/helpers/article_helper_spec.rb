require 'spec_helper'

RSpec.describe ArticleHelper do
  let(:field) { { value: Array.wrap('abc') } }

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

  it '#doi_link' do
    result = helper.doi_link(field)
    expect(result).to have_css('a @href', text: 'https://doi.org/abc')
    expect(result).to have_css('a', text: 'abc')
  end
end
