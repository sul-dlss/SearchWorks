require 'spec_helper'

describe "annotations/show", vcr: true, annos: true do
  before(:each) do
    # need the following line to avoid nested resources error in view spec:
    #   "No route matches {:action=>"show", :controller=>"annotations"}"
    allow(view).to receive(:url_for).and_return('#')
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
