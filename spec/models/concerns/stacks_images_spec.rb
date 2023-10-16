require 'rails_helper'

RSpec.describe StacksImages do
  let(:subject) { Class.new }

  before { subject.extend StacksImages }

  it 'includes an image dimensions hash' do
    expect(subject.image_dimensions).to be_a Hash
    expect(subject.image_dimensions[:default]).to eq 'full/80,80/0/default.jpg'
    expect(subject.image_dimensions[:thumbnail]).to eq 'square/100,100/0/default.jpg'
  end

  describe 'craft_image_url' do
    context 'when a druid is present explicitly' do
      it 'returns the image url given the druid, image_id, and size' do
        expect(subject.craft_image_url(druid: 'abc123', image_id: 'file-123', size: :thumbnail)).to match(
          %r{/image/iiif/abc123%2Ffile-123/square/100,100/0/default.jpg}
        )
      end

      it 'removes the .jp2 extension from the file id' do
        expect(
          subject.craft_image_url(druid: 'abc123', image_id: 'file-123.jp2', size: :thumbnail)
        ).not_to include('jp2')
      end

      it 'url-escapes the file name' do
        expect(subject.craft_image_url(druid: 'abc123', image_id: 'file 123', size: :thumbnail)).to match(
          %r{/image/iiif/abc123%2Ffile%20123/square/100,100/0/default.jpg}
        )
      end
    end

    context 'when a druid is present in the image id' do
      it 'returns the image url using the image id directly' do
        expect(subject.craft_image_url(image_id: 'druid123%2Ffile-123.jp2')).to match(%r{iiif/druid123%2Ffile-123/})
      end
    end

    describe 'size' do
      context 'when not passed' do
        it 'uses the default size' do
          expect(subject.craft_image_url(image_id: '123456')).to match(%r{/123456/full/80,80/})
        end
      end

      context 'when passed' do
        it 'uses the given size' do
          expect(subject.craft_image_url(image_id: '12345', size: :large)).to match(%r{/full/!400,400/})
        end

        it 'uses the default size if given an invalid size' do
          expect(subject.craft_image_url(image_id: '123456')).to match(%r{/full/80,80/})
        end
      end
    end
  end
end
