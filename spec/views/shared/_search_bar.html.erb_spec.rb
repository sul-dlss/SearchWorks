require 'rails_helper'

RSpec.describe 'shared/_search_bar' do
  before do
    expect(view).to receive_messages(
      search_state: double('SearchState', params_for_search: {}),
      search_action_url: '/',
      blacklight_config: Blacklight::Configuration.new,
      controller_name:
    )
  end

  describe 'input placeholder' do
    context 'article search' do
      let(:controller_name) { 'articles' }

      it 'has a contextual placeholder' do
        render

        expect(rendered).to have_css(
          'input[type="text"][placeholder="articles, e-books, & other e-resources"]'
        )
      end
    end

    context 'non-article search' do
      let(:controller_name) { 'anything-else' }

      it 'has a contextual placeholder' do
        render

        expect(rendered).to have_css(
          'input[type="text"][placeholder="books & media"]'
        )
      end
    end
  end
end
