require 'spec_helper'

describe "tags/index" do
  before(:each) do
    assign(:tags, [
      Tag.new({}),
      Tag.new({})
    ])
  end

  it "renders a list of tags" do
    render
    pending "test needs to be written"
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
