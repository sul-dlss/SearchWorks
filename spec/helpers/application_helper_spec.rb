# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#catalog_home_or_search_url' do
    context 'when there is no search term' do
      it { expect(helper.catalog_home_or_search_url).to eq Settings.CATALOG.HOME_URL }
    end

    context 'when there is a search term' do
      before { expect(helper).to receive(:params).at_least(:once).and_return({ q: 'Kittens' }) }

      it { expect(helper.catalog_home_or_search_url).to start_with Settings.CATALOG.HOME_URL }
      it { expect(helper.catalog_home_or_search_url).to include 'q=Kittens' }
    end
  end

  describe '#articles_home_or_search_url' do
    context 'when there is no search term' do
      it { expect(helper.articles_home_or_search_url).to eq Settings.ARTICLE.HOME_URL }
    end

    context 'when there is a search term' do
      before { expect(helper).to receive(:params).at_least(:once).and_return({ q: 'Kittens' }) }

      it { expect(helper.articles_home_or_search_url).to start_with Settings.ARTICLE.HOME_URL }
      it { expect(helper.articles_home_or_search_url).to include 'q=Kittens' }
    end
  end
end
