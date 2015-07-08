require "spec_helper"

describe "annotations/_tags.html.erb", annos: true do
  let(:sw_doc_id) { '333' }
  let(:tag1) {'foo'}
  let(:tag2) {'baz'}
  let(:first_tag_anno) {
    a = LD4L::OpenAnnotationRDF::TagAnnotation.new
    a.setTag tag1
    a
  }
  let(:second_tag_anno) {
    a = LD4L::OpenAnnotationRDF::TagAnnotation.new
    a.setTag tag2
    a
  }
  before(:each) do
    assign(:sw_doc_id, sw_doc_id)
  end
  it "displays Tags heading" do
    render
    expect(rendered).to have_css("h2", text: "Tags")
  end
  it 'displays individual tags' do
    assign(:annotations, [first_tag_anno, second_tag_anno])
    render
    expect(rendered).to have_css(".section-body")
    expect(rendered).to have_css(".tags")
    expect(rendered).to have_text tag1
    expect(rendered).to have_css(".tag", text: tag1)
    expect(rendered).to have_text tag2
    expect(rendered).to have_css(".tag", text: tag2)
  end
  context "create form" do
    it 'has Add tag button' do
      render
      expect(rendered).to have_css("button", text: "Add tag")
    end
    it 'has create form' do
      render
      expect(rendered).to have_css("div#create-tag/form")
    end
  end
end
