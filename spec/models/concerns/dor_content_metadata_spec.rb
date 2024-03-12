# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DorContentMetadata do
  let(:published_content) { SolrDocument.new(dor_resource_count_isi: 1) }
  let(:no_published_content) { SolrDocument.new(dor_resource_count_isi: 0) }
  let(:field_missing) { SolrDocument.new }

  describe '#published_content?' do
    it 'returns true if there is published content' do
      expect(published_content.published_content?).to be true
    end

    it 'returns false if there is no published content' do
      expect(no_published_content.published_content?).to be false
    end

    it 'returns true if the dor_resource_count_isi field is missing' do
      expect(field_missing.published_content?).to be true
    end
  end
end
