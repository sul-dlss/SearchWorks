require 'spec_helper'

describe AnnotationsController, :vcr => true do

  # This should return the minimal set of attributes required to create a valid
  # Annotation. As you add validations to Annotation, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { :motivatedBy => 'bookmarking' } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # AnnotationsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  context "GET index" do
    it 'does something' do
      pending "need to implement Annotation.all for a target"
    end
    it "assigns all annotation as @annotation" do
      pending "not sure that this will be relevant"
      anno = Annotation.create valid_attributes
      get :index, {}, valid_session
      assigns(:annotations).should eq([anno])
    end
  end

  describe "GET show" do
    it "assigns the requested annotation as @annotation" do
      # TODO: need to render all of 'em that match, not just first one
      get :show, {:id => '666'}, valid_session
      assigns(:annotation).should be_a LD4L::OpenAnnotationRDF::CommentAnnotation
    end
    it "calls Annotation.find_by_target_uri with full URL for solr id" do
      sw_id = "666"
      full_target_url = "#{Constants::CONTACT_INFO[:website][:url]}/view/#{sw_id}"
      expect(Annotation).to receive(:find_by_target_uri).with(full_target_url).and_call_original
      get :show, {:id => sw_id}, valid_session
    end
  end

  describe "GET new" do
    it "assigns a new annotation as @annotation" do
      get :new, {}, valid_session
      assigns(:annotation).should be_a_new(Annotation)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created annotation as @annotation" do
        resp = double("resp")
        allow(resp).to receive(:status).and_return(201)
        allow(resp).to receive(:headers).and_return({"Location" => 'somewhere'}).twice
        oa_storage_conn = double("oa_storage_conn")
        allow(oa_storage_conn).to receive(:post).and_return(resp)
        allow_any_instance_of(Annotation).to receive(:oa_storage_conn).and_return(oa_storage_conn)
        post :create, {:annotation => valid_attributes}, valid_session
        assigns(:annotation).should be_a(Annotation)
      end
      it 'returns status 201 if anno is successfully created' do
        resp = double("resp")
        allow(resp).to receive(:status).and_return(201)
        allow(resp).to receive(:headers).and_return({"Location" => 'somewhere'}).twice
        oa_storage_conn = double("oa_storage_conn")
        allow(oa_storage_conn).to receive(:post).and_return(resp)
        allow_any_instance_of(Annotation).to receive(:oa_storage_conn).and_return(oa_storage_conn)
        post :create, {:annotation => valid_attributes}, valid_session
        assigns(:annotation)
        expect(response.status).to eq 201
      end
      it "sends a flash message if successfully created" do
        resp = double("resp")
        allow(resp).to receive(:status).and_return(201)
        allow(resp).to receive(:headers).and_return({"Location" => 'somewhere'}).twice
        oa_storage_conn = double("oa_storage_conn")
        allow(oa_storage_conn).to receive(:post).and_return(resp)
        allow_any_instance_of(Annotation).to receive(:oa_storage_conn).and_return(oa_storage_conn)
        post :create, {:annotation => valid_attributes}, valid_session
        assigns(:annotation)
        expect(flash[:notice]).to eq 'Annotation was successfully created.'
      end
      it "returns status 500 if anno isn't successfully created" do
        resp = double("resp")
        allow(resp).to receive(:status).and_return(403)
        oa_storage_conn = double("oa_storage_conn")
        allow(oa_storage_conn).to receive(:post).and_return(resp)
        allow_any_instance_of(Annotation).to receive(:oa_storage_conn).and_return(oa_storage_conn)
        post :create, {:annotation => valid_attributes}, valid_session
        assigns(:annotation)
        expect(response.status).to eq 500
      end
      it "sends a flash message if problem creating anno" do
        resp = double("resp")
        allow(resp).to receive(:status).and_return(403)
        oa_storage_conn = double("oa_storage_conn")
        allow(oa_storage_conn).to receive(:post).and_return(resp)
        allow_any_instance_of(Annotation).to receive(:oa_storage_conn).and_return(oa_storage_conn)
        post :create, {:annotation => valid_attributes}, valid_session
        assigns(:annotation)
        expect(flash[:alert]).to eq 'There was a problem creating the Annotation.'
      end
      
      it "redirects to the created anno" do
        pending "not sure that this will be relevant"
        post :create, {:annotation => valid_attributes}, valid_session
        response.should redirect_to(Annotation.last)
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
  end

end
