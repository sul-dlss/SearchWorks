require 'spec_helper'

describe "tags/new" do
  before(:each) do
    assign(:tag, Tag.new({}))
  end

  it "renders new tag form" do
    render
    assert_select "form[action=?][method=?]", tags_path, "post" do
    end
  end
  
  it "doesn't have square brackets in the hasTarget text field" do
    render
    expect(rendered).to have_css('input#tag_hasTarget_id', text: '')
    expect(rendered).not_to have_css('input#tag_hasTarget_id', text: '[]')
  end
  
  it "doesn't have square brackets in the hasBody text area" do
    render
    expect(rendered).to have_css('textarea#tag_hasBody_id', text: '')
    expect(rendered).not_to have_css('textarea#tag_hasBody_id', text: '[]')
  end
end
