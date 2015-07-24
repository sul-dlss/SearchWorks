require 'spec_helper'

describe Annotation, vcr: true, annos: true do

  # we used to use :tag repo;  this test may be silly now
  it 'has repository set to :default' do
    expect(Annotation.repository).to be :default
  end

# Class Methods ----------------------------------------------------------------

  context '*find_by_target_uri' do
    let(:target_uri) {"http://searchworks.stanford.edu/view/666"}
    it "returns Array of LD4L::OpenAnnotationRDF::Annotation objects" do
      result = Annotation.find_by_target_uri target_uri
      expect(result).to be_a Array
      expect(result.size).to eq 6
      result.each { |anno|
        expect(anno).to be_a_kind_of LD4L::OpenAnnotationRDF::Annotation
      }
    end
    it "calls model_from_graph to populate the specific object" do
      expect(Annotation).to receive(:model_from_graph).exactly(6).times
      result = Annotation.find_by_target_uri target_uri
    end
  end

  context '*jsonld_annos_for_target_uri' do
    let(:target_uri) {"http://searchworks.stanford.edu/view/666"}
    it "Solr escapes the target_uri string" do
      escaped_url = RSolr.solr_escape(target_uri)
      expect(Annotation.oa_rsolr_conn).to receive(:get).with('select', {:params => {:q => "target_url:#{escaped_url}", :defType=>"lucene"}})
      Annotation.jsonld_annos_for_target_uri(target_uri)
    end
    it "returns Array of jsonld Strings" do
      result = Annotation.jsonld_annos_for_target_uri(target_uri)
      expect(result.size).to be > 0
      result.each { |anno_string|
        RDF::Graph.new.from_jsonld anno_string
      }
    end
  end

  context '*model_from_graph' do
    context 'tag' do
      before(:each) do
        ttl = '<https://triannon-dev.stanford.edu/annotations/2155d7f5-cd79-435f-ab86-11f1e246d3ce> a <http://www.w3.org/ns/oa#Annotation>;
                 <http://www.w3.org/ns/oa#hasBody> [
                   a <http://purl.org/dc/dcmitype/Text>,
                     <http://www.w3.org/2011/content#ContentAsText>,
                     <http://www.w3.org/ns/oa#Tag>;
                   <http://www.w3.org/2011/content#chars> "blue"
                 ];
                 <http://www.w3.org/ns/oa#hasTarget> <http://searchworks.stanford.edu/view/666>;
                 <http://www.w3.org/ns/oa#motivatedBy> <http://www.w3.org/ns/oa#tagging> .'
        @tag_anno = Annotation.model_from_graph RDF::Graph.new.from_ttl ttl
      end
      it "LD4L::OpenAnnotationRDF::TagAnnotation and its properties" do
        expect(@tag_anno).to be_a LD4L::OpenAnnotationRDF::TagAnnotation
        expect(@tag_anno.type).to eq [RDF::Vocab::OA.Annotation]
        expect(@tag_anno.motivatedBy).to eq [RDF::Vocab::OA.tagging]
        expect(@tag_anno.hasTarget.first.rdf_subject).to eq RDF::URI.new("http://searchworks.stanford.edu/view/666")
      end
      it "populates Tag bodies properly" do
        body = @tag_anno.hasBody.first
        expect(body).to be_a LD4L::OpenAnnotationRDF::TagBody
        expect(body.tag.first).to eq "blue"
        expect(body.type).to include RDF::Vocab::OA.Tag
        expect(body.type).to include RDF::Vocab::CNT.ContentAsText
        expect(body.type).to include RDF::Vocab::DCMIType.Text
        expect(body.type.size).to eq 3
        expect{body.format}.to raise_error(NoMethodError) # not in Tag model
      end
    end # tag
    context 'comment' do
      before(:each) do
        ttl = '<https://triannon-dev.stanford.edu/annotations/5051575d-6248-4ff4-a163-8cc6d59785f3> a <http://www.w3.org/ns/oa#Annotation>;
                 <http://www.w3.org/ns/oa#hasBody> [
                   a <http://purl.org/dc/dcmitype/Text>,
                     <http://www.w3.org/2011/content#ContentAsText>;
                   <http://purl.org/dc/terms/format> "text/plain";
                   <http://www.w3.org/2011/content#chars> "I am a comment!"
                 ];
                 <http://www.w3.org/ns/oa#hasTarget> <http://searchworks.stanford.edu/view/666>;
                 <http://www.w3.org/ns/oa#motivatedBy> <http://www.w3.org/ns/oa#commenting> .'
        @comment_anno = Annotation.model_from_graph RDF::Graph.new.from_ttl ttl
      end
      it "LD4L::OpenAnnotationRDF::CommentAnnotation and its properties" do
        expect(@comment_anno).to be_a LD4L::OpenAnnotationRDF::CommentAnnotation
        expect(@comment_anno.type).to eq [RDF::Vocab::OA.Annotation]
        expect(@comment_anno.motivatedBy).to eq [RDF::Vocab::OA.commenting]
        expect(@comment_anno.hasTarget.first.rdf_subject).to eq RDF::URI.new("http://searchworks.stanford.edu/view/666")
      end
      it "populates Comment bodies properly" do
        body = @comment_anno.hasBody.first
        expect(body).to be_a LD4L::OpenAnnotationRDF::CommentBody
        expect(body.content.first).to eq "I am a comment!"
        expect(body.format).to eq ["text/plain"]
        expect(body.type).to include RDF::Vocab::CNT.ContentAsText
        expect(body.type).to include RDF::Vocab::DCMIType.Text
        expect(body.type).not_to include RDF::Vocab::OA.Tag
        expect(body.type.size).to eq 2
      end
    end # comment
    context 'semantic tag' do
      before(:each) do
        ttl = '<https://triannon-dev.stanford.edu/annotations/31e9e5ea-085a-43d7-83f3-b586b3c5783f> a <http://www.w3.org/ns/oa#Annotation>;
                 <http://www.w3.org/ns/oa#hasBody> <http://dbpedia.org/resource/Love>;
                 <http://www.w3.org/ns/oa#hasTarget> <http://searchworks.stanford.edu/view/666>;
                 <http://www.w3.org/ns/oa#motivatedBy> <http://www.w3.org/ns/oa#tagging> .

              <http://dbpedia.org/resource/Love> a <http://www.w3.org/ns/oa#SemanticTag> .'
        @sem_tag_anno = Annotation.model_from_graph RDF::Graph.new.from_ttl ttl
      end
      it "LD4L::OpenAnnotationRDF::SemanticTagAnnotation and its properties" do
        expect(@sem_tag_anno).to be_a LD4L::OpenAnnotationRDF::SemanticTagAnnotation
        expect(@sem_tag_anno.type).to eq [RDF::Vocab::OA.Annotation]
        expect(@sem_tag_anno.motivatedBy).to eq [RDF::Vocab::OA.tagging]
        expect(@sem_tag_anno.hasTarget.first.rdf_subject).to eq RDF::URI.new("http://searchworks.stanford.edu/view/666")
      end
      it "populates SemanticTag bodies properly" do
        body = @sem_tag_anno.hasBody.first
        expect(body).to be_a LD4L::OpenAnnotationRDF::SemanticTagBody
        expect(body.rdf_subject).to eq RDF::URI.new "http://dbpedia.org/resource/Love"
        expect(body.type).to eq [RDF::Vocab::OA.SemanticTag]
        expect(body.type).not_to include(RDF::Vocab::OA.Tag)
        expect(body.type).not_to include(RDF::Vocab::CNT.ContentAsText)
      end
    end # semantic tag

    it "LD4L::OpenAnnotationRDF::Annotation when graph has right type" do
      ttl = '<https://triannon-dev.stanford.edu/annotations/5051575d-6248-4ff4-a163-8cc6d59785f3> a <http://www.w3.org/ns/oa#Annotation> .'
      result = Annotation.model_from_graph RDF::Graph.new.from_ttl ttl
      expect(result).to be_a LD4L::OpenAnnotationRDF::Annotation
    end
  end # *model_from_graph

  context '*anno_uri_from_graph' do
    it "returns full url for OA::Annotation from Triannon storage" do
      tid = "aaa"
      g = RDF::Graph.new.from_ttl("<#{Settings.OPEN_ANNO_REPO_STORE_URL}#{tid}> a <http://www.w3.org/ns/oa#Annotation> .")
      expect(Annotation.anno_uri_from_graph(g)).to eq "#{Settings.OPEN_ANNO_REPO_STORE_URL}#{tid}"
    end
    it "returns full url for OA::Annotation that isn't from Triannon storage" do
      tid = "aaa"
      g = RDF::Graph.new.from_ttl("<https://my_anno_url/#{tid}> a <http://www.w3.org/ns/oa#Annotation> .")
      expect(Annotation.anno_uri_from_graph(g)).to eq "https://my_anno_url/#{tid}"
    end
    it "nil for Triannon url that isn't OA::Annotation" do
      tid = "aaa"
      g = RDF::Graph.new.from_ttl("<#{Settings.OPEN_ANNO_REPO_STORE_URL}#{tid}> a <http://foo.org/thing> .")
      expect(Annotation.anno_uri_from_graph(g)).to be_nil
    end
    it "nil when graph is empty" do
      solutions = RDF::Graph.new.query Annotation.anno_query
      expect(solutions.size).to eq 0
    end
  end

  context '*anno_query' do
    it "finds solution when graph has RDF.type OA::Annotation" do
      my_url = "http://fakeurl.org/id"
      g = RDF::Graph.new.from_ttl("<#{my_url}> a <http://www.w3.org/ns/oa#Annotation> .")
      solutions = g.query Annotation.anno_query
      expect(solutions.size).to eq 1
      expect(solutions.first.s.to_s).to eq my_url
    end
    it "doesn't find solution when graph has no RDF.type OA::Annotation" do
      g = RDF::Graph.new.from_ttl("<http://anywehre.com> a <http://foo.org/thing> .")
      solutions = g.query Annotation.anno_query
      expect(solutions.size).to eq 0
    end
    it "doesn't find solution when graph is empty" do
      solutions = RDF::Graph.new.query Annotation.anno_query
      expect(solutions.size).to eq 0
    end
  end

# Instance Methods ----------------------------------------------------------------

  context '#initialize' do
    context 'motivatedBy' do
      it "full url (with OA url prefix)" do
        a = Annotation.new({"motivatedBy" => "tagging"})
        a.motivatedBy.first.should eq RDF::Vocab::OA.tagging
      end
    end
    context 'hasTarget' do
      it "is full SearchWorks url" do
        a = Annotation.new({"hasTarget" => {"id" =>"666"}})
        a.hasTarget.first.rdf_subject.to_s.should match Constants::CONTACT_INFO[:website][:url]
        a.hasTarget.first.rdf_subject.to_s.should match "http://searchworks.stanford.edu/view/666"
      end
      it "is empty array if id value is empty string" do
        a = Annotation.new({"hasTarget" => {"id" =>""}})
        expect(a.hasTarget).to eq []
      end
      it "is empty array if id value is nil" do
        a = Annotation.new({"hasTarget" => {"id" =>nil}})
        expect(a.hasTarget).to eq []
      end
      it "is empty array if missing from params" do
        a = Annotation.new({})
        expect(a.hasTarget).to eq []
        a = Annotation.new({"hasTarget" => {}})
        expect(a.hasTarget).to eq []
      end
    end # hasTarget
    context 'hasBody' do
      context 'comment anno' do
        it "is a populated CommentBody object if motivation is commenting" do
          a = Annotation.new({"motivatedBy" => "commenting", "hasBody" => {"id" =>"blah blah"}})
          body_obj = a.hasBody.first
          expect(body_obj).to be_a LD4L::OpenAnnotationRDF::CommentBody
          expect(body_obj.content.first).to eq "blah blah"
          expect(body_obj.format.first).to eq "text/plain"
        end
        it "calls LD4L::OpenAnnotationRDF::CommentBody.new" do
          expect(LD4L::OpenAnnotationRDF::CommentBody).to receive(:new).and_call_original
          Annotation.new({"motivatedBy" => "commenting", "hasBody" => {"id" =>"blah blah"}})
        end
        it "has a type of RDF::Vocab::CNT.ContentAsText if motivation is commenting" do
          a = Annotation.new({"motivatedBy" => "commenting", "hasBody" => {"id" =>"blah blah"}})
          body_obj = a.hasBody.first
          expect(body_obj.type).to include RDF::Vocab::CNT.ContentAsText
        end
      end
      context 'tag anno' do
        it "is a populated TagBody object if the motivation is tagging" do
          a = Annotation.new({"motivatedBy" => "tagging", "hasBody" => {"id" =>"blah blah"}})
          body_obj = a.hasBody.first
          expect(body_obj).to be_a LD4L::OpenAnnotationRDF::TagBody
          expect(body_obj.tag.first).to eq "blah blah"
        end
        it "calls LD4L::OpenAnnotationRDF::TagBody.new" do
          expect(LD4L::OpenAnnotationRDF::TagBody).to receive(:new).and_call_original
          Annotation.new({"motivatedBy" => "tagging", "hasBody" => {"id" =>"blah blah"}})
        end
        it "has a type of RDF::Vocab::OA.Tag if motivation is tagging" do
          a = Annotation.new({"motivatedBy" => "tagging", "hasBody" => {"id" =>"blah blah"}})
          body_obj = a.hasBody.first
          expect(body_obj.type).to include RDF::Vocab::OA.Tag
        end
      end

      it "is empty array if id value is empty string" do
        a = Annotation.new({"hasBody" => {"id" =>""}})
        expect(a.hasBody).to eq []
      end
      it "is empty array if id value is nil" do
        a = Annotation.new({"hasBody" => {"id" => nil}})
        expect(a.hasBody).to eq []
      end
      it "is empty array if missing from params" do
        a = Annotation.new({})
        expect(a.hasBody).to eq []
        a = Annotation.new({"hasBody" => {}})
        expect(a.hasBody).to eq []
      end
      it "is empty array if motivatedBy isn't tagging or commenting" do
        a = Annotation.new({"motivatedBy" => "describing", "hasBody" => {"id" =>"blah blah"}})
        expect(a.hasBody).to eq []
      end
    end # hasBody

    context 'annotatedBy' do
      it "is populated from WebAuth" do
        pending "annotatedBy to be implemented"
      end
    end
    context 'annotatedAt' do
      it "is set to DateTime.now" do
        a = Annotation.new({})
        aat = a.annotatedAt.first
        aat.class.should == DateTime
        aat.to_i.should <= DateTime.now.to_i
      end
    end
  end

  context '#graph' do
    before(:each) do
      @anno = Annotation.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}, "hasBody" => {"id" => "blah blah"}})
    end
    it "contains all triples in the Annotation object" do
      graph = @anno.send(:graph)
      @anno.each_statement { |s|
        expect(graph.query(s).size).to be > 0
      }
    end
    it 'contains all triples from the body object' do
      graph = @anno.send(:graph)
      @anno.hasBody.first.each_statement { |s|
        expect(graph.query(s).size).to be > 0
      }
    end
    context 'no hasBody statement when' do
      it 'hasBody id is empty String' do
        anno = Annotation.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}, "hasBody" => {"id" => ""}})
        graph = anno.send(:graph)
        expect(graph.query([nil, RDF::Vocab::OA.hasBody, nil]).size).to eq 0
      end
      it 'hasBody id is nil' do
        anno = Annotation.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}, "hasBody" => {"id" => nil}})
        graph = anno.send(:graph)
        expect(graph.query([nil, RDF::Vocab::OA.hasBody, nil]).size).to eq 0
      end
      it 'no hasBody id param' do
        anno = Annotation.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}, "hasBody" => {}})
        graph = anno.send(:graph)
        expect(graph.query([nil, RDF::Vocab::OA.hasBody, nil]).size).to eq 0
      end
      it 'no hasBody param' do
        anno = Annotation.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}})
        graph = anno.send(:graph)
        expect(graph.query([nil, RDF::Vocab::OA.hasBody, nil]).size).to eq 0
      end
    end
  end

  context '#save' do
    let(:user_id) {'me'}
    let(:workgroups) {['group1', 'group2']}
    before(:each) do
      @anno = Annotation.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}, "hasBody" => {"id" => "blah blah"}})
    end
    it "calls post_graph_to_oa_storage" do
      expect(@anno).to receive(:post_graph_to_oa_storage).with(user_id, workgroups)
      @anno.save(user_id, workgroups)
    end
    it "returns true if anno_store returns id" do
      allow(@anno).to receive(:post_graph_to_oa_storage).with(user_id, workgroups).and_return("666")
      expect(@anno.save(user_id, workgroups)).to be_true
    end
    it "returns false if anno_store doesn't return id" do
      allow(@anno).to receive(:access_token).and_return('fake_access_token')
      allow(@anno.send(:oa_repo_conn)).to receive(:post).and_return(Faraday::Response.new)
      expect(@anno.save(user_id, workgroups)).to be_false
    end
    it "sets triannon_id attribute" do
      expect(@anno.triannon_id).to be_nil
      allow(@anno).to receive(:post_graph_to_oa_storage).with(user_id, workgroups).and_return("666")
      @anno.save(user_id, workgroups)
      expect(@anno.triannon_id).to eq "666"
    end
    it 'does nothing if empty user_id' do
      expect(@anno).not_to receive(:post_graph_to_oa_storage)
      @anno.save(nil, workgroups)
    end
    it 'does nothing if no webauth_groups' do
      expect(@anno).not_to receive(:post_graph_to_oa_storage)
      @anno.save(user_id, nil)
      expect(@anno).not_to receive(:post_graph_to_oa_storage)
      @anno.save(user_id, [])
    end
  end

# Protected Methods ----------------------------------------------------------------

  describe "#oa_repo_conn" do
    let(:oa_repo_conn) {
      anno = Annotation.new({})
      oa_repo_conn = anno.send(:oa_repo_conn)
    }
    it "Faraday connection to OPEN_ANNO_REPO_URL in Settings.yml" do
      expect(oa_repo_conn).to be_a Faraday::Connection
      expect(oa_repo_conn.url_prefix.to_s).to match Settings.OPEN_ANNO_REPO_URL
    end
    it 'uses Faraday::CookieJar to manage cookies for session-ized requests' do
      expect(oa_repo_conn.builder.handlers).to include(Faraday::CookieJar)
    end
  end

  context '#post_graph_to_oa_storage' do
    let(:anno_ttl) {"<#{Settings.OPEN_ANNO_REPO_STORE_URL}new_anno_id> a <http://www.w3.org/ns/oa#Annotation>;
     <http://www.w3.org/ns/oa#hasTarget> <http://purl.stanford.edu/kq131cs7229>;
     <http://www.w3.org/ns/oa#motivatedBy> <http://www.w3.org/ns/oa#bookmarking> ."}
    let(:user_id) {'me'}
    let(:workgroups) {['group1', 'group2']}
    let(:fake_access_token) {'fake access token'}
    before(:each) do
      @anno = Annotation.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}, "hasBody" => {"id" => "blah blah"}})
    end
    it 'calls access_token' do
      expect(@anno).to receive(:access_token)
      @anno.send(:post_graph_to_oa_storage, user_id, workgroups)
    end
    it "doesn't post if nil access token" do
      allow(@anno).to receive(:access_token).and_return(nil)
      expect(@anno).not_to receive(:oa_repo_conn)
      @anno.send(:post_graph_to_oa_storage, user_id, workgroups)
    end
    it 'sends POST to oa_repo_conn, looks for 201 status and body' do
      allow(@anno).to receive(:access_token).and_return(fake_access_token)
      resp = double("resp")
      expect(resp).to receive(:status).and_return(201)
      expect(resp).to receive(:body)
      expect(@anno.send(:oa_repo_conn)).to receive(:post).and_return(resp)
      @anno.send(:post_graph_to_oa_storage, user_id, workgroups)
    end
    it "returns the storage id of a newly created anno" do
      allow(@anno).to receive(:access_token).and_return(fake_access_token)
      resp = double("resp")
      allow(resp).to receive(:status).and_return(201)
      allow(resp).to receive(:body).and_return(anno_ttl)
      allow(@anno.send(:oa_repo_conn)).to receive(:post).and_return(resp)
      id = @anno.send(:post_graph_to_oa_storage, user_id, workgroups)
      expect(id).to eq "new_anno_id"
    end
    it "returns nil if there was an error doing POST" do
      allow(@anno).to receive(:access_token).and_return(fake_access_token)
      allow(@anno.send(:oa_repo_conn)).to receive(:post).and_return(Faraday::Response.new)
      expect(@anno.send(:post_graph_to_oa_storage, user_id, workgroups)).to be_nil
    end
  end

  context '#triannon_id_from_triannon_url' do
    before(:each) do
      @anno = Annotation.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}, "hasBody" => {"id" => "blah blah"}})
    end
    it "returns the part of the url after the OA storage config setting" do
      exp_id = "aaa"
      expect(@anno.send(:triannon_id_from_triannon_url, "#{Settings.OPEN_ANNO_REPO_STORE_URL}#{exp_id}")).to eq exp_id
    end
    it "returns whole url if it doesn't match OA storage config setting" do
      url = "http://my_anno_url"
      expect(@anno.send(:triannon_id_from_triannon_url, url)).to eq url
    end
    it "nil if url is nil" do
      expect(@anno.send(:triannon_id_from_triannon_url, nil)).to eq nil
    end
  end

  describe "authzn for OA storage" do
    let(:anno) {Annotation.new}

    describe "#access_token" do
      let(:user_id) {'me'}
      let(:workgroups) {['group1', 'group2']}
      let(:client_auth_code) {'pretend_this_is_a_client_auth_code'}
      it 'calls client_authzn_code' do
        expect(anno).to receive(:client_authzn_code)
        anno.send(:access_token, user_id, workgroups)
      end
      it 'calls user_info_cookie' do
        allow(anno).to receive(:client_authzn_code).and_return(client_auth_code)
        expect(anno).to receive(:user_info_cookie)
        anno.send(:access_token, user_id, workgroups)
      end
      it "doesn't call user_info_cookie if no client_authzn_code" do
        allow(anno).to receive(:client_authzn_code).and_return(nil)
        expect(anno).not_to receive(:user_info_cookie)
        anno.send(:access_token, user_id, workgroups)
      end
      it "doesn't call json_to_oa_auth if user_info_cookie is false" do
        allow(anno).to receive(:client_authzn_code).and_return(client_auth_code)
        expect(anno).to receive(:user_info_cookie).and_return(false)
        expect(anno).not_to receive(:json_to_oa_auth)
        anno.send(:access_token, user_id, workgroups)
      end
      it 'gets accessToken if client_authzn_code and user_info_cookie' do
        access_token = 'some string'
        resp_body_json = { accessToken: access_token }.to_json
        resp = double("faraday_resp")
        expect(resp).to receive(:status).and_return(200)
        expect(resp).to receive(:body).and_return(resp_body_json)
        conn = double("faraday_conn")
        expect(conn).to receive(:get).and_return(resp)
        expect(anno).to receive(:oa_repo_conn).and_return(conn)
        expect(anno).to receive(:client_authzn_code).and_return(client_auth_code)
        expect(anno).to receive(:user_info_cookie).and_return(true)
        expect(anno.send(:access_token, user_id, workgroups)).to eq access_token
      end
      it "calls json_to_oa_auth with get, path 'access_token', authzn_code param" do
        resp = double("faraday_resp")
        resp_body_json = { accessToken: 'whatever' }.to_json
        expect(resp).to receive(:status).and_return(200)
        expect(resp).to receive(:body).and_return(resp_body_json)
        expect(anno).to receive(:client_authzn_code).and_return(client_auth_code)
        expect(anno).to receive(:user_info_cookie).and_return(true)
        expect(anno).to receive(:json_to_oa_auth).with(:get, 'access_token', {code: client_auth_code}).and_return(resp)
        anno.send(:access_token, user_id, workgroups)
      end
      it 'nil if resp code not 200' do
        resp = double("faraday_resp")
        expect(resp).to receive(:status).and_return(201)
        expect(anno).to receive(:json_to_oa_auth).and_return(resp)
        expect(anno.send(:access_token, user_id, workgroups)).to be_nil
      end
    end # access_token

    describe "#client_authzn_code" do
      it 'gets authzn code for SW client' do
        auth_code = 'some string'
        resp_body_json = { authorizationCode: auth_code }.to_json
        resp = double("faraday_resp")
        expect(resp).to receive(:status).and_return(200)
        expect(resp).to receive(:body).and_return(resp_body_json)
        conn = double("faraday_conn")
        expect(conn).to receive(:post).and_return(resp)
        expect(anno).to receive(:oa_repo_conn).and_return(conn)
        expect(anno.send(:client_authzn_code)).to eq auth_code
      end
      it "calls json_to_oa_auth with post, path 'client_identity' and json body with values from Settings" do
        expect(Settings).to receive(:OPEN_ANNO_REPO_CLIENT_ID)
        expect(Settings).to receive(:OPEN_ANNO_REPO_CLIENT_SECRET)
        resp = double("faraday_resp")
        resp_body_json = { authorizationCode: 'whatever' }.to_json
        expect(resp).to receive(:status).and_return(200)
        expect(resp).to receive(:body).and_return(resp_body_json)
        expect(anno).to receive(:json_to_oa_auth).with(:post, 'client_identity', {}, an_instance_of(String)).and_return(resp)
        # FIXME:  would like to check body for string passed
        anno.send(:client_authzn_code)
      end
      it 'nil if resp code not 200' do
        resp = double("faraday_resp")
        expect(resp).to receive(:status).and_return(201)
        expect(anno).to receive(:json_to_oa_auth).and_return(resp)
        expect(anno.send(:client_authzn_code)).to be_nil
      end
    end

    describe "#user_info_cookie" do
      let(:user_id) {'me'}
      let(:workgroups) {['group1', 'group2']}
      let(:client_auth_code) {'pretend_this_is_a_client_auth_code'}
      it 'true if resp code 302' do
        resp = double("faraday_resp")
        expect(resp).to receive(:status).and_return(302)
        expect(anno).to receive(:json_to_oa_auth).and_return(resp)
        expect(anno.send(:user_info_cookie, user_id, workgroups, client_auth_code)).to be_true
      end
      it "calls json_to_oa_auth with post, path 'login', authzn_code param and json body with user id and workgroups" do
        params = {code: client_auth_code}
        resp = double("faraday_resp")
        expect(resp).to receive(:status).and_return(302)
        expect(resp).not_to receive(:body)
        expect(anno).to receive(:json_to_oa_auth).with(:post, 'login', params, an_instance_of(String)).and_return(resp)
        # FIXME:  would like to check body for string passed
        anno.send(:user_info_cookie, user_id, workgroups, client_auth_code)
      end
      it 'false if resp code not 302' do
        resp = double("faraday_resp")
        expect(resp).to receive(:status).and_return(200)
        expect(anno).to receive(:json_to_oa_auth).and_return(resp)
        expect(anno.send(:user_info_cookie, user_id, workgroups, client_auth_code)).to be_false
      end
    end

    describe "#json_to_oa_auth" do
      it 'sends request to oa_repo_conn and returns response' do
        resp = double("resp")
        conn = double("faraday_conn")
        expect(conn).to receive(:post).and_return(resp)
        expect(anno).to receive(:oa_repo_conn).and_return(conn)
        expect(anno.send(:json_to_oa_auth, :post, nil)).to eq resp
      end
    end
  end

end
