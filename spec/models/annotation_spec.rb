require 'spec_helper'

describe Annotation, :vcr => true do

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
      expect(result.size).to eq 3
      expect(result.first).to be_a LD4L::OpenAnnotationRDF::Annotation
    end
    it "calls model_from_graph to populate the specific object" do
      expect(Annotation).to receive(:model_from_graph).exactly(3).times
      result = Annotation.find_by_target_uri target_uri
    end
  end
  
  context '*jsonld_annos_for_target_uri' do
    let(:target_uri) {"http://searchworks.stanford.edu/view/666"}
    it "Solr escapes the target_uri string" do
      escaped_url = Annotation.solr_escape(target_uri)
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
        expect(@tag_anno.type).to eq [RDF::OpenAnnotation.Annotation]
        expect(@tag_anno.motivatedBy).to eq [RDF::OpenAnnotation.tagging]
        expect(@tag_anno.hasTarget.first.rdf_subject).to eq RDF::URI.new("http://searchworks.stanford.edu/view/666")
      end
      it "populates Tag bodies properly" do
        body = @tag_anno.hasBody.first
        expect(body).to be_a LD4L::OpenAnnotationRDF::TagBody
        expect(body.tag.first).to eq "blue"
        expect(body.type).to include RDF::OpenAnnotation.Tag
        expect(body.type).to include RDF::Content.ContentAsText
        expect(body.type).to include RDF::DCMIType.Text
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
        expect(@comment_anno.type).to eq [RDF::OpenAnnotation.Annotation]
        expect(@comment_anno.motivatedBy).to eq [RDF::OpenAnnotation.commenting]
        expect(@comment_anno.hasTarget.first.rdf_subject).to eq RDF::URI.new("http://searchworks.stanford.edu/view/666")
      end
      it "populates Comment bodies properly" do
        body = @comment_anno.hasBody.first
        expect(body).to be_a LD4L::OpenAnnotationRDF::CommentBody
        expect(body.content.first).to eq "I am a comment!"
        expect(body.format).to eq ["text/plain"]
        expect(body.type).to include RDF::Content.ContentAsText
        expect(body.type).to include RDF::DCMIType.Text
        expect(body.type).not_to include RDF::OpenAnnotation.Tag
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
        expect(@sem_tag_anno.type).to eq [RDF::OpenAnnotation.Annotation]
        expect(@sem_tag_anno.motivatedBy).to eq [RDF::OpenAnnotation.tagging]
        expect(@sem_tag_anno.hasTarget.first.rdf_subject).to eq RDF::URI.new("http://searchworks.stanford.edu/view/666")
      end
      it "populates SemanticTag bodies properly" do
        body = @sem_tag_anno.hasBody.first
        expect(body).to be_a LD4L::OpenAnnotationRDF::SemanticTagBody
        expect(body.rdf_subject).to eq RDF::URI.new "http://dbpedia.org/resource/Love"
        expect(body.type).to eq [RDF::OpenAnnotation.SemanticTag]
        expect(body.type).not_to include(RDF::OpenAnnotation.Tag)
        expect(body.type).not_to include(RDF::Content.ContentAsText)
      end
    end # semantic tag

    it "LD4L::OpenAnnotationRDF::Annotation when graph has right type" do
      ttl = '<https://triannon-dev.stanford.edu/annotations/5051575d-6248-4ff4-a163-8cc6d59785f3> a <http://www.w3.org/ns/oa#Annotation> .'
      result = Annotation.model_from_graph RDF::Graph.new.from_ttl ttl
      expect(result).to be_a LD4L::OpenAnnotationRDF::Annotation
    end
  end # *model_from_graph
  
  context '*triannon_id_from_graph' do
    it "returns unique part of triannon url for Triannon OA::Annotation" do
      tid = "aaa"
      g = RDF::Graph.new.from_ttl("<#{Settings.OPEN_ANNOTATION_STORE_URL}#{tid}> a <http://www.w3.org/ns/oa#Annotation> .")
      expect(Annotation.triannon_id_from_graph(g)).to eq tid
    end
    it "returns full url for OA::Annotation that isn't from Triannon storage" do
      tid = "aaa"
      g = RDF::Graph.new.from_ttl("<http://my_anno_url/#{tid}> a <http://www.w3.org/ns/oa#Annotation> .")
      expect(Annotation.triannon_id_from_graph(g)).to eq "http://my_anno_url/#{tid}"
    end
    it "nil for Triannon url that isn't OA::Annotation" do
      tid = "aaa"
      g = RDF::Graph.new.from_ttl("<#{Settings.OPEN_ANNOTATION_STORE_URL}#{tid}> a <http://foo.org/thing> .")
      expect(Annotation.triannon_id_from_graph(g)).to be_nil
    end
    it "nil when graph is empty" do
      solutions = RDF::Graph.new.query Annotation.anno_query
      expect(solutions.size).to eq 0
    end
  end

  context '*triannon_id_from_triannon_url' do
    it "returns the part of the url after the OA storage config setting" do
      exp_id = "aaa"
      expect(Annotation.triannon_id_from_triannon_url("#{Settings.OPEN_ANNOTATION_STORE_URL}#{exp_id}")).to eq exp_id
    end
    it "returns whole url if it doesn't match OA storage config setting" do
      url = "http://my_anno_url"
      expect(Annotation.triannon_id_from_triannon_url(url)).to eq url
    end
    it "nil if url is nil" do
      expect(Annotation.triannon_id_from_triannon_url(nil)).to eq nil
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

  context '*solr_escape' do
    it "adds backslash to Solr query syntax chars" do
      # per http://lucene.apache.org/core/4_0_0/queryparser/org/apache/lucene/queryparser/classic/package-summary.html#Escaping_Special_Characters
      special_chars = [ "+", "-", "&", "|", "!", "(", ")", "{", "}", "[", "]", "^", '"', "~", "*", "?", ":", "\\", "/" ]
      escaped_str = Annotation.solr_escape("aa#{special_chars.join('aa')}aa")
      special_chars.each { |c|  
        expect(escaped_str).to match "\\#{c}"
      }
    end
    it "leaves other chars alone" do
      str = "nothing to see here; let's move along people."
      expect(Annotation.solr_escape(str)).to eq str
    end
  end

# Instance Methods ----------------------------------------------------------------

  context '#initialize' do
    context 'motivatedBy' do
      it "full url (with OA url prefix)" do
        t = Annotation.new({"motivatedBy" => "tagging"})
        t.motivatedBy.first.should eq RDF::OpenAnnotation.tagging
      end
    end
    context 'hasTarget' do
      it "is full SearchWorks url" do
        t = Annotation.new({"hasTarget" => {"id" =>"666"}})
        t.hasTarget.first.rdf_subject.to_s.should match Constants::CONTACT_INFO[:website][:url]
        t.hasTarget.first.rdf_subject.to_s.should match "http://searchworks.stanford.edu/view/666"
      end
      it "is empty array if id value is empty string" do
        t = Annotation.new({"hasTarget" => {"id" =>""}})
        expect(t.hasTarget).to eq []
      end
      it "is empty array if id value is nil" do
        t = Annotation.new({"hasTarget" => {"id" =>nil}})
        expect(t.hasTarget).to eq []
      end
      it "is empty array if missing from params" do
        t = Annotation.new({})
        expect(t.hasTarget).to eq []
        t = Annotation.new({"hasTarget" => {}})
        expect(t.hasTarget).to eq []
      end
    end # hasTarget
    context 'hasBody' do
      it "is a populated CommentBody object" do
        t = Annotation.new({"hasBody" => {"id" =>"blah blah"}})
        body_obj = t.hasBody.first
        expect(body_obj).to be_a LD4L::OpenAnnotationRDF::CommentBody
        expect(body_obj.content.first).to eq "blah blah"
        expect(body_obj.format.first).to eq "text/plain"
      end

      it "is empty array if id value is empty string" do
        t = Annotation.new({"hasBody" => {"id" =>""}})
        expect(t.hasBody).to eq []
      end
      it "is empty array if id value is nil" do
        t = Annotation.new({"hasBody" => {"id" => nil}})
        expect(t.hasBody).to eq []
      end
      it "is empty array if missing from params" do
        t = Annotation.new({})
        expect(t.hasBody).to eq []
        t = Annotation.new({"hasBody" => {}})
        expect(t.hasBody).to eq []
      end
    end # hasBody

    context 'annotatedBy' do
      it "is populated from WebAuth" do
        pending "annotatedBy to be implemented"
      end
    end
    context 'annotatedAt' do
      it "is set to DateTime.now" do
        t = Annotation.new({})
        a = t.annotatedAt.first
        a.class.should == DateTime
        a.to_i.should <= DateTime.now.to_i
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
        expect(graph.query([nil, RDF::OpenAnnotation.hasBody, nil]).size).to eq 0
      end
      it 'hasBody id is nil' do
        anno = Annotation.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}, "hasBody" => {"id" => nil}})
        graph = anno.send(:graph)
        expect(graph.query([nil, RDF::OpenAnnotation.hasBody, nil]).size).to eq 0
      end
      it 'no hasBody id param' do
        anno = Annotation.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}, "hasBody" => {}})
        graph = anno.send(:graph)
        expect(graph.query([nil, RDF::OpenAnnotation.hasBody, nil]).size).to eq 0
      end
      it 'no hasBody param' do
        anno = Annotation.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}})
        graph = anno.send(:graph)
        expect(graph.query([nil, RDF::OpenAnnotation.hasBody, nil]).size).to eq 0
      end
    end
  end
  
  context '#save' do
    before(:each) do
      @anno = Annotation.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}, "hasBody" => {"id" => "blah blah"}})
    end
    it "calls post_graph_to_oa_storage" do
      expect(@anno).to receive(:post_graph_to_oa_storage)
      @anno.save
    end
    it "returns true if anno_store returns id" do
      allow(@anno).to receive(:post_graph_to_oa_storage).and_return("666")
      expect(@anno.save).to be_true
    end
    it "returns false if anno_store doesn't return id" do
      allow(@anno.send(:oa_storage_conn)).to receive(:post).and_return(Faraday::Response.new)
      expect(@anno.save).to be_false
    end
    it "sets triannon_id attribute" do
      expect(@anno.triannon_id).to be_nil
      allow(@anno).to receive(:post_graph_to_oa_storage).and_return("666")
      @anno.save
      expect(@anno.triannon_id).to eq "666"
    end
  end
    
# Protected Methods ----------------------------------------------------------------
  
  it "#oa_storage_conn is Faraday connection to OPEN_ANNOTATION_STORE_URL in Settings.yml" do
    anno = Annotation.new({})
    oa_storage_conn = anno.send(:oa_storage_conn)
    expect(oa_storage_conn).to be_a Faraday::Connection
    expect(oa_storage_conn.url_prefix.to_s).to match Settings.OPEN_ANNOTATION_STORE_URL
  end
  
  context '#post_graph_to_oa_storage' do
    before(:each) do
      @anno = Annotation.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}, "hasBody" => {"id" => "blah blah"}})
    end
    it 'sends POST to oa_storage_conn, looks for 201 status and Location header' do
      resp = double("resp")
      expect(resp).to receive(:status).and_return(201)
      expect(resp).to receive(:headers).and_return({"Location" => 'somewhere'}).twice
      expect(@anno.send(:oa_storage_conn)).to receive(:post).and_return(resp)
      @anno.send(:post_graph_to_oa_storage)
    end 
    it "returns the storage id (from resp.headers['Location']) of a newly created anno" do
      resp = double("resp")
      expect(resp).to receive(:status).and_return(201)
      expect(resp).to receive(:headers).and_return({"Location" => "#{Settings.OPEN_ANNOTATION_STORE_URL}new_id"}).twice
      expect(@anno.send(:oa_storage_conn)).to receive(:post).and_return(resp)
      id = @anno.send(:post_graph_to_oa_storage)
      expect(id).to eq "new_id"
    end
    it "returns nil if there was an error" do
      expect(@anno.send(:oa_storage_conn)).to receive(:post).and_return(Faraday::Response.new)
      expect(@anno.send(:post_graph_to_oa_storage)).to be_nil
    end
  end
  
end
