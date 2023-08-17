# frozen_string_literal: true

require 'rails_helper'

describe 'search/_module_heading' do
  let(:catalog) do
    double('QuickSearch::CatalogSearcher', loaded_link: 'https://searchworks.stanford.edu/articles?q=climate%20change')
  end

  before do
    without_partial_double_verification do
      allow(view).to receive_messages(service_name: 'catalog', total: 0, searcher: catalog)
    end
    render
  end

  it 'renders if there are no results' do
    expect(rendered).to have_css('.result-set-heading', text: 'Catalog')
    expect(rendered).to have_css('.result-set-subheading', text: /Physical and digital/)
  end
end
