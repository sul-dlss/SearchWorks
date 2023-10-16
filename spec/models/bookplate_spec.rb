require 'rails_helper'

RSpec.describe Bookplate do
  let(:data) { 'FUND-NAME -|- druid:abc123 -|- file-id-abc123.jp2 -|- BOOKPLATE-TEXT' }
  let(:subject) { described_class.new(data) }

  describe 'accessors' do
    it 'gets the thumbnail_url' do
      expect(subject.thumbnail_url).to match(
        %r{/image/iiif/abc123%2Ffile-id-abc123/full/!400,400/0/default.jpg$}
      )
    end

    it 'gets the bookplate text' do
      expect(subject.text).to eq 'BOOKPLATE-TEXT'
    end

    it 'gets the params hash representing a facet search' do
      expect(subject.params_for_search).to be_a Hash
      expect(subject.params_for_search[:f]).to be_a Hash
      expect(subject.params_for_search[:f][:fund_facet]).to eq ['abc123']
    end
  end

  describe '#matches?' do
    it 'does not match when the params are empty' do
      expect(subject.matches?({})).to be false
    end

    it 'does not match if the druid is different' do
      expect(subject.matches?({ f: { fund_facet: ['something'] } })).to be false
    end

    it 'matches if the druid in the facet matches this fund' do
      expect(subject.matches?({ f: { fund_facet: ['abc123'] } })).to be true
    end

    it 'matches if the fund name in the facet matches this fund' do
      expect(subject.matches?({ f: { fund_facet: ['FUND-NAME'] } })).to be true
    end
  end

  describe 'to_partial_path' do
    it 'returns the bookplates path' do
      expect(subject.to_partial_path).to eq 'bookplates/bookplate'
    end
  end
end
