require "spec_helper"

describe "annotations/_comments.html.erb", annos: true do
  let(:sw_doc_id) { '999' }
  let(:comment1) { 'I am the first comment' }
  let(:comment2) { 'second comment rocks' }
  let(:first_comment_anno) {
    a = LD4L::OpenAnnotationRDF::CommentAnnotation.new
    a.setComment comment1
    a
  }
  let(:second_comment_anno) {
    a = LD4L::OpenAnnotationRDF::CommentAnnotation.new
    a.setComment comment2
    a
  }
  before(:each) do
    assign(:sw_doc_id, sw_doc_id)
  end
  it "displays Comments heading with number of comments" do
    assign(:annotations, [first_comment_anno, second_comment_anno])
    render
    expect(rendered).to have_css("h2", text: "User comments (2)")
    expect(rendered).to have_css("h2>span.num-found", text: "(2)")
  end
  it 'displays individual comments' do
    assign(:annotations, [first_comment_anno, second_comment_anno])
    render
    expect(rendered).to have_css(".section-body")
    expect(rendered).to have_css(".user-comments")
    expect(rendered).to have_text comment1
    expect(rendered).to have_css("li", text: comment1)
    expect(rendered).to have_text comment2
    expect(rendered).to have_css("li", text: comment2)
  end
  context "create form" do
    it 'has Add comment button' do
      render
      expect(rendered).to have_css("button", text: "Add comment")
    end
    it 'has create form' do
      render
      expect(rendered).to have_css("#create-comments")
    end
    it 'fills in sw_id value in the create form' do
      render
      expect(rendered).to have_css("#sw-id[value*=\"#{sw_doc_id}\"]")
    end
    it 'sets motivation to commenting' do
      render
      expect(rendered).to have_css('#motivation[value*="oa:commenting"]')
    end
    it 'has text-comment input field' do
      render
      expect(rendered).to have_css(".text-annotation[name*=\"text-tag\"]")
    end
  end
end
