require 'spec_helper'

describe 'catalog/_search_form.html.erb' do
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
        expect(view).to receive_messages(has_search_parameters?: false)
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

  context 'article search' do
    before { expect(view).to receive_messages(controller_name: 'articles') }

    describe 'default options facet params' do
      context 'when there are no query parameters' do
        before { expect(view).to receive_messages(has_search_parameters?: false) }

        it 'renders a hidden field for eds_search_limiters_facet' do
          render

          expect(rendered).to have_css(
            'input[type="hidden"][name="f[eds_search_limiters_facet][]"][value="Stanford has it"]',
            visible: false
          )
        end
      end

      context 'when there are query parameters' do
        before { expect(view).to receive_messages(has_search_parameters?: true) }

        it 'does not render a hidden field for eds_search_limiters_facet' do
          render

          expect(rendered).not_to have_css(
            'input[type="hidden"][name="f[eds_search_limiters_facet][]"][value="Stanford has it"]',
            visible: false
          )
        end
      end
    end
  end
end
