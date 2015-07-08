require "spec_helper"

describe "annotations/_create_anno.html.erb", annos: true do
  let(:sw_doc_id) { '999' }
  let(:tag_locals) {{anno_type: "tag", motivation_str: "oa:tagging"}}
  let(:comment_locals) {{anno_type: "comment", motivation_str: "oa:commenting"}}
  before(:each) do
    assign(:sw_doc_id, sw_doc_id)
  end
  context "outer div" do
    it 'id is create-tag for anno_type tag' do
      render partial: "annotations/create_anno.html.erb", locals: tag_locals
      expect(rendered).to have_css("div#create-tag/form")
    end
    it 'id is create-comment for anno_type comment' do
      render partial: "annotations/create_anno.html.erb", locals: comment_locals
      expect(rendered).to have_css("div#create-comment/form")
    end
    it 'data-anno-store_url = Settings.OPEN_ANNOTATION_STORE_URL' do
      render partial: "annotations/create_anno.html.erb", locals: tag_locals
      expect(rendered).to have_css("div[data-anno-store-url='#{Settings.OPEN_ANNOTATION_STORE_URL}']/form")
    end
  end
  context "form" do
    it 'post method' do
      render partial: "annotations/create_anno.html.erb", locals: tag_locals
      expect(rendered).to have_css("form[method='post']")
    end
    it 'class form-annotations' do
      render partial: "annotations/create_anno.html.erb", locals: tag_locals
      expect(rendered).to have_css("form.form-annotations")
    end
    it 'supplies sw_id value' do
      render partial: "annotations/create_anno.html.erb", locals: comment_locals
      expect(rendered).to have_css("form/input#sw-id[value=\"#{sw_doc_id}\"]")
    end
    it 'motivation = local motivation_str' do
      render partial: "annotations/create_anno.html.erb", locals: tag_locals
      expect(rendered).to have_css("form/input#motivation[value='#{tag_locals[:motivation_str]}']")
    end
    it 'authenticity-token = Settings.OPEN_ANNOTATION_POST_AUTH_TOKEN' do
      render partial: "annotations/create_anno.html.erb", locals: tag_locals
      expect(rendered).to have_css("form/input#authenticity-token[value='#{Settings.OPEN_ANNOTATION_POST_AUTH_TOKEN}']")
    end
    it '"Save" submit button' do
      render partial: "annotations/create_anno.html.erb", locals: tag_locals
      expect(rendered).to have_css("button[type='submit']", text: "Save")
    end
    it 'Cancel link' do
      render partial: "annotations/create_anno.html.erb", locals: tag_locals
      expect(rendered).to have_css("a.cancel-link[href='javascript:;']", text: "Cancel")
    end
    context "tag form" do
      it 'class form-create-tag' do
        render partial: "annotations/create_anno.html.erb", locals: tag_locals
        expect(rendered).to have_css("form.form-create-tag")
      end
      context "text-tag" do
        it 'label Tag' do
          render partial: "annotations/create_anno.html.erb", locals: tag_locals
          expect(rendered).to have_css("div[class='form-group']/label[for='text-tag']", :text => "Tag")
        end
        it 'input with id text-tag, class text-annotation and name text-tag' do
          render partial: "annotations/create_anno.html.erb", locals: tag_locals
          expect(rendered).to have_css("div[class='form-group']/div/input#text-tag.text-annotation[name='text-tag']")
        end
      end
    end
    context "comment form" do
      it 'class form-create-comment' do
        render partial: "annotations/create_anno.html.erb", locals: comment_locals
        expect(rendered).to have_css("form.form-create-comment")
      end
      context "text-tag" do
        it 'label Comment' do
          render partial: "annotations/create_anno.html.erb", locals: comment_locals
          expect(rendered).to have_css("div[class='form-group']/label[for='text-tag']", :text => "Comment")
        end
        it 'textarea with id text-tag, class text-annotation and name text-tag' do
          render partial: "annotations/create_anno.html.erb", locals: comment_locals
          expect(rendered).to have_css("div[class='form-group']/div/textarea#text-tag.text-annotation[name='text-tag']")
        end
        it 'textarea has 5 rows' do
          render partial: "annotations/create_anno.html.erb", locals: comment_locals
          expect(rendered).to have_css("div[class='form-group']/div/textarea#text-tag[rows='5']")
        end
      end
    end
  end # form
end
