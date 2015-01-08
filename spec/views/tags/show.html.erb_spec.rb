require 'spec_helper'

describe "tags/show" do
  before(:each) do
    @tag = assign(:tag,  Tag.new({}))
  end

  it "renders attributes in <p>" do
    render
    pending "test needs to be written"
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
