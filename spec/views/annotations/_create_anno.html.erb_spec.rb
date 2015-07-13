require "spec_helper"

describe "annotations/_create_anno.html.erb", annos: true do
  let(:sw_doc_id) { '999' }
  let(:tag_locals) {{anno_type: "tag", motivation_str: "tagging", sw_doc_id: sw_doc_id}}
  let(:comment_locals) {{anno_type: "comment", motivation_str: "commenting", sw_doc_id: sw_doc_id}}
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
    it 'action /annotations' do
      render partial: "annotations/create_anno.html.erb", locals: tag_locals
      expect(rendered).to have_css("form[action='/annotations']")
    end
    it 'class form-annotations' do
      render partial: "annotations/create_anno.html.erb", locals: tag_locals
      expect(rendered).to have_css("form.form-annotations")
    end
    context "hidden fields" do
      it 'annotation_hasTarget_id (id) with name annotation[hasBody][id] and value @sw_doc_id' do
        render partial: "annotations/create_anno.html.erb", locals: comment_locals
        expect(rendered).to have_css("form/input#annotation_hasTarget_id[value=\"#{sw_doc_id}\"][type='hidden'][name='annotation[hasTarget][id]']")
      end
      context "annotation_motivatedBy" do
        it 'value = local motivation_str' do
          render partial: "annotations/create_anno.html.erb", locals: tag_locals
          expect(rendered).to have_css("form/input#annotation_motivatedBy[value='#{tag_locals[:motivation_str]}'][type='hidden']")
        end
        it 'name = annotation[motivatedBy]' do
          render partial: "annotations/create_anno.html.erb", locals: tag_locals
          expect(rendered).to have_css("form/input#annotation_motivatedBy[name='annotation[motivatedBy]'][type='hidden']")
        end
      end
      it 'oa-store-authenticity-token = Settings.OPEN_ANNOTATION_POST_AUTH_TOKEN' do
        render partial: "annotations/create_anno.html.erb", locals: tag_locals
        expect(rendered).to have_css("form/input#oa-store-authenticity-token[value='#{Settings.OPEN_ANNOTATION_POST_AUTH_TOKEN}']")
      end
    end
    it '"Save" submit "button"' do
      render partial: "annotations/create_anno.html.erb", locals: tag_locals
      expect(rendered).to have_css("input[type='submit'][name='commit'][value='Save']")
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
      context "annotation_hasBody_id" do
        it 'label Tag' do
          render partial: "annotations/create_anno.html.erb", locals: tag_locals
          expect(rendered).to have_css("div[class='form-group']/label[for='annotation_hasBody_id']", :text => "Tag")
        end
        it 'input with id annotation_hasBody_id, class text-annotation and name annotation[hasBody][id]' do
          render partial: "annotations/create_anno.html.erb", locals: tag_locals
          expect(rendered).to have_css("div[class='form-group']/div/input#annotation_hasBody_id.text-annotation[name='annotation[hasBody][id]']")
        end
      end
    end
    context "comment form" do
      it 'class form-create-comment' do
        render partial: "annotations/create_anno.html.erb", locals: comment_locals
        expect(rendered).to have_css("form.form-create-comment")
      end
      context "annotation_hasBody_id" do
        it 'label Comment' do
          render partial: "annotations/create_anno.html.erb", locals: comment_locals
          expect(rendered).to have_css("div[class='form-group']/label[for='annotation_hasBody_id']", :text => "Comment")
        end
        it 'textarea with id annotation_hasBody_id, class text-annotation and name annotation_hasBody_id' do
          render partial: "annotations/create_anno.html.erb", locals: comment_locals
          expect(rendered).to have_css("div[class='form-group']/div/textarea#annotation_hasBody_id.text-annotation[name='annotation[hasBody][id]']")
        end
        it 'textarea has 5 rows' do
          render partial: "annotations/create_anno.html.erb", locals: comment_locals
          expect(rendered).to have_css("div[class='form-group']/div/textarea#annotation_hasBody_id[rows='5']")
        end
      end
    end
  end # form
end
