require 'spec_helper'

describe StacksImages do
  let(:subject) { Class.new }
  before { subject.extend StacksImages }

  it 'includes an image dimensions hash' do
    expect(subject.image_dimensions).to be_a Hash
    expect(subject.image_dimensions[:default]).to eq 'full/80,80/0/default.jpg'
    expect(subject.image_dimensions[:thumbnail]).to eq 'square/100,100/0/default.jpg'
  end

  describe 'craft_image_url' do
    it 'returns the image url given the druid, image_id, and size' do
      expect(subject.craft_image_url('abc123', 'file-123', :thumbnail)).to match(
        %r{/image/iiif/abc123%2Ffile-123/square/100,100/0/default.jpg}
      )
    end

    it 'removes the .jp2 extension from the file id' do
      expect(subject.craft_image_url('abc123', 'file-123.jp2', :thumbnail)).not_to include('jp2')
    end
  end
end
