require 'spec_helper'

describe Tag do

  # we used to use :tag repo;  this test may be silly now
  it 'has repository set to :default' do
    expect(Tag.repository).to be :default
  end
  
# Class Methods ----------------------------------------------------------------
  
  context '*triannon_id_from_anno_graph' do
    it "returns unique part of triannon url for Triannon OA::Annotation" do
      tid = "aaa"
      g = RDF::Graph.new.from_ttl("<#{Settings.OPEN_ANNOTATION_STORE_URL}#{tid}> a <http://www.w3.org/ns/oa#Annotation> .")
      expect(Tag.triannon_id_from_anno_graph(g)).to eq tid
    end
    it "returns full url for OA::Annotation that isn't from Triannon storage" do
      tid = "aaa"
      g = RDF::Graph.new.from_ttl("<http://my_anno_url/#{tid}> a <http://www.w3.org/ns/oa#Annotation> .")
      expect(Tag.triannon_id_from_anno_graph(g)).to eq "http://my_anno_url/#{tid}"
    end
    it "nil for Triannon url that isn't OA::Annotation" do
      tid = "aaa"
      g = RDF::Graph.new.from_ttl("<#{Settings.OPEN_ANNOTATION_STORE_URL}#{tid}> a <http://foo.org/thing> .")
      expect(Tag.triannon_id_from_anno_graph(g)).to be_nil
    end
    it "nil when graph is empty" do
      solutions = RDF::Graph.new.query Tag.anno_query
      expect(solutions.size).to eq 0
    end
  end

  context '*triannon_id_from_triannon_url' do
    it "returns the part of the url after the OA storage config setting" do
      exp_id = "aaa"
      expect(Tag.triannon_id_from_triannon_url("#{Settings.OPEN_ANNOTATION_STORE_URL}#{exp_id}")).to eq exp_id
    end
    it "returns whole url if it doesn't match OA storage config setting" do
      url = "http://my_anno_url"
      expect(Tag.triannon_id_from_triannon_url(url)).to eq url
    end
    it "nil if url is nil" do
      expect(Tag.triannon_id_from_triannon_url(nil)).to eq nil
    end
  end
  
  context '*anno_query' do
    it "finds solution when graph has RDF.type OA::Annotation" do
      my_url = "http://fakeurl.org/id"
      g = RDF::Graph.new.from_ttl("<#{my_url}> a <http://www.w3.org/ns/oa#Annotation> .")
      solutions = g.query Tag.anno_query
      expect(solutions.size).to eq 1
      expect(solutions.first.s.to_s).to eq my_url
    end
    it "doesn't find solution when graph has no RDF.type OA::Annotation" do
      g = RDF::Graph.new.from_ttl("<http://anywehre.com> a <http://foo.org/thing> .")
      solutions = g.query Tag.anno_query
      expect(solutions.size).to eq 0
    end
    it "doesn't find solution when graph is empty" do
      solutions = RDF::Graph.new.query Tag.anno_query
      expect(solutions.size).to eq 0
    end
  end

# Instance Methods ----------------------------------------------------------------

  context '#initialize' do
    context 'motivatedBy' do
      it "full url (with OA url prefix)" do
        t = Tag.new({"motivatedBy" => "tagging"})
        t.motivatedBy.first.should eq RDF::OpenAnnotation.tagging
      end
    end
    context 'hasTarget' do
      it "is full SearchWorks url" do
        t = Tag.new({"hasTarget" => {"id" =>"666"}})
        t.hasTarget.first.rdf_subject.to_s.should match Constants::CONTACT_INFO[:website][:url]
        t.hasTarget.first.rdf_subject.to_s.should match "http://searchworks.stanford.edu/view/666"
      end
      it "is empty array if id value is empty string" do
        t = Tag.new({"hasTarget" => {"id" =>""}})
        expect(t.hasTarget).to eq []
      end
      it "is empty array if id value is nil" do
        t = Tag.new({"hasTarget" => {"id" =>nil}})
        expect(t.hasTarget).to eq []
      end
      it "is empty array if missing from params" do
        t = Tag.new({})
        expect(t.hasTarget).to eq []
        t = Tag.new({"hasTarget" => {}})
        expect(t.hasTarget).to eq []
      end
    end # hasTarget
    context 'hasBody' do
      it "is a populated TagTextBody object" do
        t = Tag.new({"hasBody" => {"id" =>"blah blah"}})
        body_obj = t.hasBody.first
        expect(body_obj).to be_a TagTextBody
        expect(body_obj.content.first).to eq "blah blah"
        expect(body_obj.format.first).to eq "text/plain"
      end

      it "is empty array if id value is empty string" do
        t = Tag.new({"hasBody" => {"id" =>""}})
        expect(t.hasBody).to eq []
      end
      it "is empty array if id value is nil" do
        t = Tag.new({"hasBody" => {"id" => nil}})
        expect(t.hasBody).to eq []
      end
      it "is empty array if missing from params" do
        t = Tag.new({})
        expect(t.hasBody).to eq []
        t = Tag.new({"hasBody" => {}})
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
        t = Tag.new({})
        a = t.annotatedAt.first
        a.class.should == DateTime
        a.to_i.should <= DateTime.now.to_i
      end
    end
  end
  
  context '#anno_graph' do
    before(:each) do
      @tag = Tag.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}, "hasBody" => {"id" => "blah blah"}})
    end
    it "contains all triples in the Tag object" do
      anno_graph = @tag.send(:anno_graph)
      @tag.each_statement { |s|
        expect(anno_graph.query(s).size).to be > 0
      }
    end
    it 'contains all triples from the body object' do
      anno_graph = @tag.send(:anno_graph)
      @tag.hasBody.first.each_statement { |s|
        expect(anno_graph.query(s).size).to be > 0
      }
    end
    context 'no hasBody statement when' do
      it 'hasBody id is empty String' do
        tag = Tag.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}, "hasBody" => {"id" => ""}})
        anno_graph = tag.send(:anno_graph)
        expect(anno_graph.query([nil, RDF::OpenAnnotation.hasBody, nil]).size).to eq 0
      end
      it 'hasBody id is nil' do
        tag = Tag.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}, "hasBody" => {"id" => nil}})
        anno_graph = tag.send(:anno_graph)
        expect(anno_graph.query([nil, RDF::OpenAnnotation.hasBody, nil]).size).to eq 0
      end
      it 'no hasBody id param' do
        tag = Tag.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}, "hasBody" => {}})
        anno_graph = tag.send(:anno_graph)
        expect(anno_graph.query([nil, RDF::OpenAnnotation.hasBody, nil]).size).to eq 0
      end
      it 'no hasBody param' do
        tag = Tag.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}})
        anno_graph = tag.send(:anno_graph)
        expect(anno_graph.query([nil, RDF::OpenAnnotation.hasBody, nil]).size).to eq 0
      end
    end
  end
  
  context '#save' do
    before(:each) do
      @tag = Tag.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}, "hasBody" => {"id" => "blah blah"}})
    end
    it "calls post_anno_graph_to_storage" do
      expect(@tag).to receive(:post_anno_graph_to_storage)
      @tag.save
    end
    it "returns true if anno_store returns id" do
      allow(@tag).to receive(:post_anno_graph_to_storage).and_return("666")
      expect(@tag.save).to be_true
    end
    it "returns false if anno_store doesn't return id" do
      allow(@tag.send(:conn)).to receive(:post).and_return(Faraday::Response.new)
      expect(@tag.save).to be_false
    end
    it "sets triannon_id attribute" do
      expect(@tag.triannon_id).to be_nil
      allow(@tag).to receive(:post_anno_graph_to_storage).and_return("666")
      @tag.save
      expect(@tag.triannon_id).to eq "666"
    end
  end
    
# Protected Methods ----------------------------------------------------------------
  
  it "#conn is Faraday connection to OPEN_ANNOTATION_STORE_URL in Settings.yml" do
    tag = Tag.new({})
    conn = tag.send(:conn)
    expect(conn).to be_a Faraday::Connection
    expect(conn.url_prefix.to_s).to match Settings.OPEN_ANNOTATION_STORE_URL
  end
  
  context '#post_anno_graph_to_storage' do
    before(:each) do
      @tag = Tag.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}, "hasBody" => {"id" => "blah blah"}})
    end
    it 'sends POST to conn, looks for 201 status and Location header' do
      resp = double("resp")
      expect(resp).to receive(:status).and_return(201)
      expect(resp).to receive(:headers).and_return({"Location" => 'somewhere'}).twice
      expect(@tag.send(:conn)).to receive(:post).and_return(resp)
      @tag.send(:post_anno_graph_to_storage)
    end 
    it "returns the storage id (from resp.headers['Location']) of a newly created anno" do
      resp = double("resp")
      expect(resp).to receive(:status).and_return(201)
      expect(resp).to receive(:headers).and_return({"Location" => "#{Settings.OPEN_ANNOTATION_STORE_URL}new_id"}).twice
      expect(@tag.send(:conn)).to receive(:post).and_return(resp)
      id = @tag.send(:post_anno_graph_to_storage)
      expect(id).to eq "new_id"
    end
    it "returns nil if there was an error" do
      expect(@tag.send(:conn)).to receive(:post).and_return(Faraday::Response.new)
      expect(@tag.send(:post_anno_graph_to_storage)).to be_nil
    end
  end
  
end
