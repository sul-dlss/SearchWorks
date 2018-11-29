require 'spec_helper'

RSpec.describe PresenterResearchStarter do
  subject(:presenter) do
    Class.new do
      include PresenterResearchStarter
    end.new
  end

  let(:view_context) do
    Class.new do
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::SanitizeHelper
      def article_path(id:)
        "/articles/#{id}"
      end
    end.new
  end

  subject(:result) { presenter.transform_research_starter_text }

  before do
    config = double(Blacklight::Configuration, show: double)
    allow(presenter).to receive(:configuration).and_return(config)
    allow(presenter).to receive(:view_context).and_return(view_context)
    allow(presenter).to receive(:document).and_return(document)
  end

  context '#transform_research_starter_text' do
    let(:document) { { 'eds_html_fulltext' => value } }
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
        context "#{tag}" do
          let(:value) { "<#{tag}>abc</#{tag}>" }

          it do
            expect(result).to eq value
          end
        end
      end
    end
  end
end
