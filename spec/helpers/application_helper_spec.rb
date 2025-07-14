# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe "#active_class_for_current_page" do
    let(:advanced_page) { "advanced" }

    it "is active" do
      helper.request.path = "advanced"
      expect(helper.active_class_for_current_page(advanced_page)).to eq "active"
    end
    it "is not active" do
      helper.request.path = "feedback"
      expect(helper.active_class_for_current_page(advanced_page)).to be_nil
    end
  end

  describe "#disabled_class_for_no_selections" do
    it "is disabled" do
      expect(helper.disabled_class_for_no_selections(0)).to eq "disabled"
    end
    it "is not disabled" do
      expect(helper.disabled_class_for_no_selections(1)).to be_nil
    end
  end

  describe "#from_advanced_search" do
    it "indicates if we are coming from the advanced search form" do
      params[:search_field] = 'advanced'
      expect(helper.from_advanced_search?).to be_truthy
    end
  end

  describe '#link_to_catalog_search' do
    subject(:result) { Capybara.string(helper.link_to_catalog_search) }

    before do
      allow(helper).to receive(:blacklight_config).and_return(double(index: double(search_field_mapping: { title: :search_title })))
    end

    it 'passes parameters if currently in article search' do
      params[:q] = 'my query'
      expect(helper).to receive(:article_search?).at_least(:once).and_return(true)
      expect(result).to have_link(text: /catalog/, href: '/?q=my+query')
    end
    it 'is an aria-current anchor link if currently in catalog search' do
      expect(helper).to receive(:article_search?).at_least(:once).and_return(false)
      expect(result.find('a[href="#"]', text: /catalog/)['aria-current']).to eq 'true'
    end
    it 'performs a mapping between fielded search' do
      params[:q] = 'my query'
      params[:search_field] = 'title'
      expect(helper).to receive(:article_search?).at_least(:once).and_return(true)
      expect(result).to have_link(text: /catalog/, href: '/?q=my+query&search_field=search_title')
    end
  end

  describe '#link_to_article_search' do
    subject(:result) { Capybara.string(helper.link_to_article_search) }

    before do
      allow(helper).to receive(:blacklight_config).and_return(double(index: double(search_field_mapping: { search_title: :title })))
    end

    it 'passes parameters if currently in catalog search' do
      params[:q] = 'my query'
      expect(helper).to receive(:article_search?).at_least(:once).and_return(false)
      expect(result).to have_link(text: /articles/, href: '/articles?q=my+query')
    end
    it 'does not link if currently in article search' do
      expect(helper).to receive(:article_search?).at_least(:once).and_return(true)
      expect(result.find('a[href="#"]', text: /articles/)['aria-current']).to eq 'true'
    end
    it 'performs a mapping between fielded search' do
      params[:q] = 'my query'
      params[:search_field] = 'search_title'
      expect(helper).to receive(:article_search?).at_least(:once).and_return(false)
      expect(result).to have_link(text: /articles/, href: '/articles?q=my+query&search_field=title')
    end
  end

  describe '#link_to_bento_search' do
    subject(:result) { Capybara.string(helper.link_to_bento_search) }

    it 'passes query to bento search params' do
      controller.params = { q: 'my query' }
      expect(result).to have_link(
        text: /all/,
        href: 'https://library.stanford.edu/all/?q=my+query'
      )
    end
  end

  describe '#link_to_library_search' do
    subject(:result) { Capybara.string(helper.link_to_library_website_search) }

    before do
      allow(helper).to receive(:blacklight_config).and_return(double(index: double(search_field_mapping: { search_title: :title })))
    end

    it 'passes query to library website search params and does not pass search fields' do
      controller.params = { q: 'kittens' }
      expect(result).to have_link(text: /library website/, href: 'https://library.stanford.edu/search/all?search=kittens')
    end
  end

  describe '#ezproxy_database_link' do
    subject(:link) { helper.ezproxy_database_link(url, title) }
    let(:link_title) { 'title' }

    context 'with a URL matching a SUL proxied host' do
      let(:url) { 'https://research.ebsco.com/whatever' }

      it 'returns a proxy URL' do
        expect(link).to eq('https://stanford.idm.oclc.org/login?qurl=https%3A%2F%2Fresearch.ebsco.com%2Fwhatever')
      end
    end

    context 'with a URL not matching a SUL proxied host' do
      let(:url) { 'https://not.website.com/whatever' }

      it 'returns the URL in its original form' do
        expect(link).to eq(url)
      end
    end
  end
end
