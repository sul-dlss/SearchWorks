# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Image object' do
  subject do
    SolrDocument.new(
      file_id: file_ids
    )
  end

  describe '#image_urls' do
    context 'when there are .jp2' do
      let(:file_ids) { ['abc123%2Fxyz321.jp2'] }

      it 'is present' do
        expect(subject.image_urls).to be_present
      end

      it 'constructs the appropriate stacks url stripping of .jp2' do
        expect(subject.image_urls.length).to eq 1
        expect(subject.image_urls.first).to match(%r{/image/iiif/abc123%2Fxyz321/})
      end
    end

    context 'when there are no .jp2' do
      let(:file_ids) { ['abc123%2Fxyz321'] }

      it 'is not present' do
        expect(subject.image_urls).not_to be_present
      end
    end

    context 'when there are no file ids' do
      let(:file_ids) { nil }

      it 'is not present' do
        expect(subject.image_urls).not_to be_present
      end
    end
  end
end
