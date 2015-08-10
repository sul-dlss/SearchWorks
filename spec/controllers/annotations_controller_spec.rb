require 'spec_helper'

describe AnnotationsController, vcr: true, annos: true do

  # Return the minimal set of values that should be in the session in order to pass any filters (e.g. authentication) defined in
  let(:valid_session) { {} }

  describe "GET show" do
    it '@sw_doc_id is set to :id from params' do
      sw_id = "666"
      get :show, {:id => sw_id}, valid_session
      expect(assigns(:sw_doc_id)).to eq sw_id
    end
    it "calls Annotation.find_by_target_uri with full URL for solr id" do
      sw_id = "666"
      full_target_url = "#{Constants::CONTACT_INFO[:website][:url]}/view/#{sw_id}"
      expect(Annotation).to receive(:find_by_target_uri).with(full_target_url).and_call_original
      get :show, {:id => sw_id}, valid_session
    end
    it 'populates @annotations Array with annotations with SW id as target' do
      get :show, {:id => '666'}, valid_session
      my_annos = assigns(:annotations)
      expect(my_annos).to be_an Array
      expect(my_annos.size).to eq 6
      my_annos.each { |anno|
        expect(anno).to be_a_kind_of LD4L::OpenAnnotationRDF::Annotation
      }
    end
    it '@annotations can have both tag and comment annos' do
      get :show, {:id => '666'}, valid_session
      my_annos = assigns(:annotations)
      includes_tag_anno = false
      includes_comment_anno = false
      my_annos.each { |anno|
        includes_tag_anno = true if anno.instance_of? LD4L::OpenAnnotationRDF::TagAnnotation
        includes_comment_anno = true if anno.instance_of? LD4L::OpenAnnotationRDF::CommentAnnotation
      }
      expect(includes_tag_anno).to be_true
      expect(includes_comment_anno).to be_true
    end
  end

  describe "GET new" do
    it "assigns a new annotation as @annotation" do
      get :new, {}, valid_session
      assigns(:annotation).should be_a_new(Annotation)
    end
  end

  describe "POST create" do
    let(:user) { double('user') }
    before do
      allow(user).to receive(:to_key)
      allow(user).to receive(:authenticatable_salt)
      allow(user).to receive(:sunet).and_return('jstanford')
      allow(user).to receive(:webauth_groups=)
      allow(user).to receive(:webauth_groups).and_return(["dlss:triannon-searchworks-users"])
      @request.env["devise.mapping"] = Devise.mappings[user]
      sign_in(:user, user)
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "with valid params" do
      let(:target_id) {"foo"}
      # Return the minimal set of attributes required to create a valid Annotation.
      let(:valid_attributes) { {:motivatedBy => 'commenting', :hasTarget => {:id => target_id}} }
      let(:anno_ttl) {"<#{Settings.OPEN_ANNO_REPO_STORE_URL}new_anno_id> a <http://www.w3.org/ns/oa#Annotation>;
   <http://www.w3.org/ns/oa#hasTarget> <http://purl.stanford.edu/kq131cs7229>;
   <http://www.w3.org/ns/oa#motivatedBy> <http://www.w3.org/ns/oa#bookmarking> ."}

      context "success" do
        it "assigns a newly created annotation as @annotation" do
          resp = double("resp")
          allow(resp).to receive(:status).and_return(201)
          allow(resp).to receive(:body).twice
          oa_repo_conn = double("oa_repo_conn")
          allow(oa_repo_conn).to receive(:post).and_return(resp)
          allow_any_instance_of(Annotation).to receive(:oa_repo_conn).and_return(oa_repo_conn)
          post :create, {:annotation => valid_attributes}, valid_session
          assigns(:annotation).should be_a(Annotation)
        end
        it 'returns status 302' do
          resp = double("resp")
          allow(resp).to receive(:status).and_return(201)
          allow(resp).to receive(:body).and_return(anno_ttl).twice
          oa_repo_conn = double("oa_repo_conn")
          allow(oa_repo_conn).to receive(:post).and_return(resp)
          allow_any_instance_of(Annotation).to receive(:access_token).and_return('fake_access_token')
          allow_any_instance_of(Annotation).to receive(:oa_repo_conn).and_return(oa_repo_conn)
          post :create, {:annotation => valid_attributes}, valid_session
          assigns(:annotation)
          expect(response.status).to eq 302
        end
        it "redirects to the catalog controller show view for target id" do
          resp = double("resp")
          allow(resp).to receive(:status).and_return(201)
          allow(resp).to receive(:body).and_return(anno_ttl).twice
          oa_repo_conn = double("oa_repo_conn")
          allow(oa_repo_conn).to receive(:post).and_return(resp)
          allow_any_instance_of(Annotation).to receive(:access_token).and_return('fake_access_token')
          allow_any_instance_of(Annotation).to receive(:oa_repo_conn).and_return(oa_repo_conn)
          post :create, {:annotation => valid_attributes}, valid_session
          response.should redirect_to(catalog_path(target_id))
        end
        it "displays a flash message" do
          resp = double("resp")
          allow(resp).to receive(:status).and_return(201)
          allow(resp).to receive(:body).and_return(anno_ttl).twice
          oa_repo_conn = double("oa_repo_conn")
          allow(oa_repo_conn).to receive(:post).and_return(resp)
          allow_any_instance_of(Annotation).to receive(:access_token).and_return('fake_access_token')
          allow_any_instance_of(Annotation).to receive(:oa_repo_conn).and_return(oa_repo_conn)
          post :create, {:annotation => valid_attributes}, valid_session
          assigns(:annotation)
          expect(flash[:notice]).to eq 'Annotation was successfully created. (You may need to refresh this page to see it.)'
        end
      end
      context "no success" do
        it "returns status 500" do
          resp = double("resp")
          allow(resp).to receive(:status).and_return(403)
          oa_repo_conn = double("oa_repo_conn")
          allow(oa_repo_conn).to receive(:post).and_return(resp)
          allow_any_instance_of(Annotation).to receive(:oa_repo_conn).and_return(oa_repo_conn)
          post :create, {:annotation => valid_attributes}, valid_session
          assigns(:annotation)
          expect(response.status).to eq 500
        end
        it "displays a flash error" do
          resp = double("resp")
          allow(resp).to receive(:status).and_return(403)
          oa_repo_conn = double("oa_repo_conn")
          allow(oa_repo_conn).to receive(:post).and_return(resp)
          allow_any_instance_of(Annotation).to receive(:oa_repo_conn).and_return(oa_repo_conn)
          post :create, {:annotation => valid_attributes}, valid_session
          assigns(:annotation)
          expect(flash[:error]).to eq "There was a problem creating the Annotation (for #{target_id}): "
        end
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved annotation as @annotation" do
        # Trigger the behavior that occurs when invalid params are submitted
        Annotation.any_instance.stub(:save).and_return(false)
        post :create, {:annotation => {  }}, valid_session
        assigns(:annotation).should be_a_new(Annotation)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Annotation.any_instance.stub(:save).and_return(false)
        post :create, {:annotation => {  }}, valid_session
        response.should render_template("new")
      end
    end
  end # POST create

end
