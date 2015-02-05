require 'spec_helper'

describe "annotations/index", :vcr => true do
  before(:each) do
    assign(:annotations, [
      Annotation.new({}),
      Annotation.new({})
    ])
  end

  it "renders a list of annotations" do
    render
    pending "test needs to be written"
  end
end
