require 'spec_helper'

describe 'catalog/_search_form.html.erb' do
  before do
    expect(view).to receive_messages(
      search_state: double('SearchState', params_for_search: {}),
      blacklight_config: Blacklight::Configuration.new
    )
  end

  context 'article search' do
    before { expect(view).to receive_messages(article_search?: true) }

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
