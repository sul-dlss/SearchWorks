require 'spec_helper'

RSpec.describe PresenterFulltextLinks do
  subject(:presenter) do
    Class.new do
      include PresenterFulltextLinks
    end.new
  end

  let(:view_context) do
    Class.new do
      include ActionView::Helpers::UrlHelper
    end.new
  end

  let(:document) { { 'eds_fulltext_links' => Array.wrap({ 'label' => 'My label', 'url' => 'http://example.com' }) } }

  before do
    config = double(Blacklight::Configuration, index: double(fulltext_links_field: 'eds_fulltext_links'))
    expect(presenter).to receive(:configuration).and_return(config)
    expect(presenter).to receive(:view_context).and_return(view_context)
    expect(presenter).to receive(:document).and_return(document)
  end

  context '#fulltext_links' do
    it 'assumes EDS API returns a hash with label and url'
    it 'renders a list of labeled links' do
      result = Capybara.string(presenter.fulltext_links.first)
      expect(result).to have_css('li.article-fulltext-link', count: 1)
      expect(result).to have_css('li a', text: 'My label')
      expect(result).to have_css('li a @href', text: 'http://example.com')
    end
    it 'uses the URL as a label when label is missing' do
      document['eds_fulltext_links'].first.delete('label')
      result = Capybara.string(presenter.fulltext_links.first)
      expect(result).to have_css('li.article-fulltext-link', count: 1)
      expect(result).to have_css('li a', text: 'http://example.com')
      expect(result).to have_css('li a @href', text: 'http://example.com')
    end
  end
end
