require 'spec_helper'

describe "annotations/show", vcr: true, annos: true do
  before(:each) do
    # need the following line to avoid error (view spec does not infer action in partial)
    #   "No route matches {:action=>"index", :controller=>"annotations"}"
    controller.request.action = "create"
  end
  it 'renders _tags partial' do
    render
    expect(view).to render_template(partial: "_tags")
  end
  it 'renders _comments partial' do
    render
    expect(view).to render_template(partial: "_comments")
  end
  it 'has heading with sw solr doc id' do
    sw_doc_id = "5437"
    assign(:sw_doc_id, sw_doc_id)
    render
    expect(rendered).to have_css("h1", text: "Annotations for Record #{sw_doc_id}")
  end
end
