require 'spec_helper'

describe AnnotationsController do

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
      tid = "2155d7f5-cd79-435f-ab86-11f1e246d3ce"
      jsonld = '{
                  "@context": {
                    "content": "http://www.w3.org/2011/content#",
                    "dc": "http://purl.org/dc/terms/",
                    "dcmitype": "http://purl.org/dc/dcmitype/",
                    "openannotation": "http://www.w3.org/ns/oa#"
                  },
                  "@graph": [
                    {
                      "@id": "_:g70171526504060",
                      "@type": [
                        "dcmitype:Text",
                        "content:ContentAsText",
                        "openannotation:Tag"
                      ],
                      "content:chars": "blue",
                      "dc:format": "text/plain"
                    },
                    {
                      "@id": "https://triannon-dev.stanford.edu/annotations/2155d7f5-cd79-435f-ab86-11f1e246d3ce",
                      "@type": "openannotation:Annotation",
                      "openannotation:hasBody": {
                        "@id": "_:g70171526504060"
                      },
                      "openannotation:hasTarget": {
                        "@id": "http://searchworks.stanford.edu/view/666"
                      },
                      "openannotation:motivatedBy": {
                        "@id": "openannotation:tagging"
                      }
                    }
                  ]
                }'
      resp = double("resp")
      expect(resp).to receive(:body).and_return(jsonld)
      conn = double("conn")
      expect(conn).to receive(:get).and_return(resp)
      expect(Annotation).to receive(:conn).and_return(conn)
      get :show, {:id => tid}, valid_session
      assigns(:annotation).should be_a LD4L::OpenAnnotationRDF::TagAnnotation
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
        conn = double("conn")
        allow(conn).to receive(:post).and_return(resp)
        allow_any_instance_of(Annotation).to receive(:conn).and_return(conn)
        post :create, {:annotation => valid_attributes}, valid_session
        assigns(:annotation).should be_a(Annotation)
      end
      it 'returns status 201 if anno is successfully created' do
        resp = double("resp")
        allow(resp).to receive(:status).and_return(201)
        allow(resp).to receive(:headers).and_return({"Location" => 'somewhere'}).twice
        conn = double("conn")
        allow(conn).to receive(:post).and_return(resp)
        allow_any_instance_of(Annotation).to receive(:conn).and_return(conn)
        post :create, {:annotation => valid_attributes}, valid_session
        assigns(:annotation)
        expect(response.status).to eq 201
      end
      it "sends a flash message if successfully created" do
        resp = double("resp")
        allow(resp).to receive(:status).and_return(201)
        allow(resp).to receive(:headers).and_return({"Location" => 'somewhere'}).twice
        conn = double("conn")
        allow(conn).to receive(:post).and_return(resp)
        allow_any_instance_of(Annotation).to receive(:conn).and_return(conn)
        post :create, {:annotation => valid_attributes}, valid_session
        assigns(:annotation)
        expect(flash[:notice]).to eq 'Annotation was successfully created.'
      end
      it "returns status 500 if anno isn't successfully created" do
        resp = double("resp")
        allow(resp).to receive(:status).and_return(403)
        conn = double("conn")
        allow(conn).to receive(:post).and_return(resp)
        allow_any_instance_of(Annotation).to receive(:conn).and_return(conn)
        post :create, {:annotation => valid_attributes}, valid_session
        assigns(:annotation)
        expect(response.status).to eq 500
      end
      it "sends a flash message if problem creating anno" do
        resp = double("resp")
        allow(resp).to receive(:status).and_return(403)
        conn = double("conn")
        allow(conn).to receive(:post).and_return(resp)
        allow_any_instance_of(Annotation).to receive(:conn).and_return(conn)
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
