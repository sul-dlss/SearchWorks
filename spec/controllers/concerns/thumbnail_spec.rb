require 'rails_helper'

class ThumbnailTestClass
  include Thumbnail
end

RSpec.describe Thumbnail do
  let(:view_context) { double(:view_context) }
  let(:thumbnail) { ThumbnailTestClass.new }
  let(:doc) { { id: '123' } }

  it "should provide a thumbnail method" do
    expect(thumbnail).to respond_to(:thumbnail)
  end
  it "should invoke the #render_cover_image method of the included view context" do
    expect(thumbnail).to receive(:view_context).and_return(view_context)
    expect(view_context).to receive(:render_cover_image).with(doc, {}).and_return('thumbnail-markup')
    expect(thumbnail.thumbnail(doc)).to eq 'thumbnail-markup'
  end
end
