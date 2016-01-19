require 'spec_helper'

describe 'Image object' do
  let(:display_type) { nil }
  subject do
    SolrDocument.new(
      id: 4488,
      druid: 4488,
      display_type: display_type,
      file_id: ['abc123defg.jp2']
    )
  end

  describe '#image_urls' do
    context 'for images' do
      let(:display_type) { ['image'] }

      it 'is present' do
        expect(subject.image_urls).to be_present
      end

      it 'constructs the appropriate Stacks url' do
        expect(subject.image_urls.length).to eq 1
        expect(subject.image_urls.first).to match(%r{/image/iiif/4488%2Fabc123defg/})
      end
    end

    context 'for books' do
      let(:display_type) { ['book'] }

      it 'returns the image urls' do
        expect(subject.image_urls).to be_present
      end
    end

    context 'for other display types' do
      let(:display_type) { ['file'] }

      it 'returns nil' do
        expect(subject.image_urls).to be_nil
      end
    end
  end
end
