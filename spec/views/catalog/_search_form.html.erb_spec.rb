require 'spec_helper'

describe 'catalog/_search_form' do
  before do
    expect(view).to receive_messages(
      search_state: double('SearchState', params_for_search: {}),
      blacklight_config: Blacklight::Configuration.new
    )
  end

  describe 'input placeholder' do
    context 'article search' do
      before do
        expect(view).to receive_messages(controller_name: 'articles')
      end

      it 'has a contextual placeholder' do
        render

        expect(rendered).to have_css(
          'input[type="text"][placeholder="articles, e-books, & other e-resources"]'
        )
      end
    end

    context 'non-article search' do
      before { expect(view).to receive_messages(controller_name: 'anything-else') }

      it 'has a contextual placeholder' do
        render

        expect(rendered).to have_css(
          'input[type="text"][placeholder="books & media"]'
        )
      end
    end
  end
end
