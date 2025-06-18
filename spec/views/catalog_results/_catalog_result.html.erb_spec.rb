# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog_results/_catalog_result' do
  before do
    render 'catalog_results/catalog_result', catalog_result:
  end

  context 'with a Book' do
    let(:catalog_result) do
      CatalogResult.new(
        format: 'Book',
        title: 'Title',
        link: 'http://example.com',
        author: 'The Author',
        pub_year: '2022'
      )
    end

    it 'displays the Book format' do
      expect(rendered).to have_content('Book')
    end

    it 'displays the formatted publication year' do
      expect(rendered).to have_content('(2022)')
    end
  end
end
