require 'spec_helper'

describe "annotations/new", :vcr => true do
  before(:each) do
    assign(:annotation, Annotation.new({}))
  end

  it "renders new annotation form" do
    render
    assert_select "form[action=?][method=?]", annotations_path, "post" do
    end
  end
  
  it "doesn't have square brackets in the hasTarget text field" do
    render
    expect(rendered).to have_css('input#annotation_hasTarget_id', text: '')
    expect(rendered).not_to have_css('input#annotation_hasTarget_id', text: '[]')
  end
  
  it "doesn't have square brackets in the hasBody text area" do
    render
    expect(rendered).to have_css('textarea#annotation_hasBody_id', text: '')
    expect(rendered).not_to have_css('textarea#annotation_hasBody_id', text: '[]')
  end
end
