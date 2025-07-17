# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe "#from_advanced_search" do
    it "indicates if we are coming from the advanced search form" do
      params[:search_field] = 'advanced'
      expect(helper.from_advanced_search?).to be_truthy
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
