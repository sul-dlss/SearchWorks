require 'spec_helper'

describe "annotations/show", :vcr => true do
  let(:sw_id) {"666"}
  let(:solr_response_start) {"{
                            'responseHeader'=>{
                              'status'=>0,
                              'QTime'=>4,
                              'params'=>{
                                'q'=>'food'}},
                            'response'=>{'numFound'=>4,'start'=>0,'maxScore'=>1.047625,'docs'=>
                              [" }
  let(:solr_response_end) {" ]
                            },
                            'facet_counts'=>{
                              'facet_queries'=>{},
                              'facet_fields'=>{
                                'motivation'=>[
                                  'tagging',3,
                                  'commenting',1],
                                'target_type'=>[
                                  'external_URI',4],
                                'body_type'=>[
                                  'content_as_text',4],
                                'annotated_at_tdate'=>[]},
                              'facet_dates'=>{},
                              'facet_ranges'=>{} 
                            }
                           }" }
  
  shared_examples_for 'Annotation display' do
    it "triannon id" do
      expect(rendered).to match /<a href="http:\/\/your\.triannon-server\.com\/annotations\//
    end
    it "motivation(s)" do
      expect(rendered).to match /<a href="http:\/\/www.w3.org\/ns\/oa\#.*ing"/
    end
    it "target(s)" do
      expect(rendered).to match /<a href="http:\/\/searchworks.stanford.edu\/view\//
    end
    it "annotated at" do
      expect(rendered).to match /2015-02-02T/
    end
    it "annotation model" do
      expect(rendered).to match /LD4L::OpenAnnotationRDF::.*Annotation/
    end
  end
  
  describe 'CommentAnnotation' do
    before(:each) do
      comment_anno_solr_doc = "{
          'id'=>'0baba6ca-4e4f-487a-8862-18eb307079b3',
          'motivation'=>['commenting'],
          'annotated_at'=>'2015-02-02T18:12:01Z',
          'target_url'=>['http://searchworks.stanford.edu/view/666'],
          'target_type'=>['external_URI'],
          'body_type'=>['content_as_text'],
          'body_chars_exact'=>['I luvs my food'],
          'anno_jsonld'=>'{\"@context\":\"http://www.w3.org/ns/oa.jsonld\",\"@graph\":[{\"@id\":\"_:g70153076581040\",\"@type\":[\"dctypes:Text\",\"cnt:ContentAsText\"],\"chars\":\"I luvs my food\",\"dcterms:format\":\"text/plain\"},{\"@id\":\"http://your.triannon-server.com/annotations/0baba6ca-4e4f-487a-8862-18eb307079b3\",\"@type\":\"oa:Annotation\",\"hasBody\":\"_:g70153076581040\",\"hasTarget\":\"http://searchworks.stanford.edu/view/666\",\"motivatedBy\":\"oa:commenting\",\"oa:annotatedAt\":{\"@value\":\"2015-02-02T18:12:01Z\",\"@type\":\"xsd:dateTime\"}}]}',
          '_version_'=>1492200001168736256,
          'timestamp'=>'2015-02-04T18:00:16.024Z',
          'score'=>0.21014 
        }"
      allow(Annotation.oa_rsolr_conn).to receive(:get).and_return(eval("#{solr_response_start}#{comment_anno_solr_doc}#{solr_response_end}"))
      @comment_anno = Annotation.find_by_target_uri(sw_id).first
      assign(:annotation, @comment_anno)
      render
    end
    it_behaves_like "Annotation display"
    it "comment annotation model" do
      expect(rendered).to match /LD4L::OpenAnnotationRDF::CommentAnnotation/
    end
    it "content" do
      expect(rendered).to match /content: /
      expect(rendered).to have_content("I luvs my food")
    end
    it "format" do
      expect(rendered).to match /format: /
      pending "this test passes but not in rake ci context"
      expect(rendered).to have_content("text/plain")
    end
    it "shouldn't display phantom blank nodes for bodies" do
      # view gets [], [], ...
      expect(rendered).not_to match /\[\],/
      assign(:annotation, @comment_anno)
      render
      expect(rendered).not_to match /\[\],/
    end
  end
  
  describe 'TagAnnotation' do
    before(:each) do
      tag_jsonld = '{
        "@context":"http://www.w3.org/ns/oa.jsonld",
        "@graph":[
          {"@id":"_:g43350240",
            "@type":["dctypes:Text","cnt:ContentAsText","oa:Tag"],
            "chars":"all the way",
            "dcterms:format":"text/plain"
          },
          {"@id":"http://your.triannon-server.com/annotations/16460005-8aa8-444b-9956-fb74996cb124",
            "@type":"oa:Annotation",
            "hasBody":"_:g43350240",
            "hasTarget":"http://searchworks.stanford.edu/view/666",
            "motivatedBy":"oa:tagging",
            "oa:annotatedAt":{"@value":"2015-02-02T18:12:01Z","@type":"xsd:dateTime"}
          }]}'
      tag_anno_solr_doc = "{
          'id'=>'22f1dcd0-cfa1-47b6-a115-4c970cf95a7a',
          'motivation'=>['tagging'],
          'annotated_at'=>'2015-02-02T18:12:01Z',
          'target_url'=>['http://searchworks.stanford.edu/view/666'],
          'target_type'=>['external_URI'],
          'body_type'=>['content_as_text'],
          'body_chars_exact'=>['food'],
          'anno_jsonld'=>'#{tag_jsonld}',
          '_version_'=>1492200022420226048,
          'timestamp'=>'2015-02-04T18:00:36.323Z',
          'score'=>1.047625
        }"
      allow(Annotation.oa_rsolr_conn).to receive(:get).and_return(eval("#{solr_response_start}#{tag_anno_solr_doc}#{solr_response_end}"))
      @tag_anno = Annotation.find_by_target_uri(sw_id).first
      assign(:annotation, @tag_anno)
      render
    end
    it_behaves_like "Annotation display"
    it "tag annotation model" do
      expect(rendered).to match /LD4L::OpenAnnotationRDF::TagAnnotation/
    end
    it "content" do
      expect(rendered).to match /tag: /
    end
    it "shouldn't display phantom blank nodes for bodies" do
      # view gets [], [], ...
      expect(rendered).not_to match /\[\],/
      assign(:annotation, @tag_anno)
      render
      expect(rendered).not_to match /\[\],/
    end
  end

  describe 'SemanticTagAnnotation' do
    before(:each) do
      semantic_tag_jsonld = '{
          "@context": {
            "openannotation": "http://www.w3.org/ns/oa#"
          },
          "@graph": [
            {
              "@id": "http://dbpedia.org/resource/Love",
              "@type": "openannotation:SemanticTag"
            },
            {
              "@id": "http://your.triannon-server.com/annotations/31e9e5ea-085a-43d7-83f3-b586b3c5783f",
              "@type": "openannotation:Annotation",
              "openannotation:annotatedAt":{
                "@value":"2015-02-02T02:02:02Z","@type":"xsd:dateTime"
              },
              "openannotation:hasBody": {
                "@id": "http://dbpedia.org/resource/Love"
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
      semantic_tag_anno_solr_doc = "{
          'id'=>'31e9e5ea-085a-43d7-83f3-b586b3c5783f',
          'motivation'=>['tagging'],
          'annotated_at'=>'2015-02-02T02:02:02Z',
          'target_url'=>['http://searchworks.stanford.edu/view/666'],
          'target_type'=>['external_URI'],
          'body_type'=>['external_URI'],
          'anno_jsonld'=>'#{semantic_tag_jsonld}',
          '_version_'=>1492200022420226048,
          'timestamp'=>'2015-02-04T14:14:14.666Z',
          'score'=>1.047625
        }"
      allow(Annotation.oa_rsolr_conn).to receive(:get).and_return(eval("#{solr_response_start}#{semantic_tag_anno_solr_doc}#{solr_response_end}"))
      semantic_tag_anno = Annotation.find_by_target_uri(sw_id).first
      assign(:annotation, semantic_tag_anno)
      render
    end
    it_behaves_like "Annotation display"
    it "semantic tag annotation model" do
      expect(rendered).to match /LD4L::OpenAnnotationRDF::SemanticTagAnnotation/
    end
  end

  describe 'unrecognized Annotation model' do
    before(:each) do
      # unrec b/c no   type oa:Tag  on body node
      unrec_anno_solr_doc = "{
          'id'=>'22f1dcd0-cfa1-47b6-a115-4c970cf95a7a',
          'motivation'=>['tagging'],
          'annotated_at'=>'2015-02-02T18:12:01Z',
          'target_url'=>['http://searchworks.stanford.edu/view/666'],
          'target_type'=>['external_URI'],
          'body_type'=>['content_as_text'],
          'body_chars_exact'=>['food'],
          'anno_jsonld'=>'{\"@context\":\"http://www.w3.org/ns/oa.jsonld\",\"@graph\":[{\"@id\":\"_:g70153135527660\",\"@type\":[\"dctypes:Text\",\"cnt:ContentAsText\"],\"chars\":\"food\",\"dcterms:format\":\"text/plain\"},{\"@id\":\"http://your.triannon-server.com/annotations/22f1dcd0-cfa1-47b6-a115-4c970cf95a7a\",\"@type\":\"oa:Annotation\",\"hasBody\":\"_:g70153135527660\",\"hasTarget\":\"http://searchworks.stanford.edu/view/666\",\"motivatedBy\":\"oa:describing\",\"oa:annotatedAt\":{\"@value\":\"2015-02-02T18:13:13Z\",\"@type\":\"xsd:dateTime\"}}]}',
          '_version_'=>1492200022420226048,
          'timestamp'=>'2015-02-04T18:00:36.323Z',
          'score'=>1.047625
        }"
      allow(Annotation.oa_rsolr_conn).to receive(:get).and_return(eval("#{solr_response_start}#{unrec_anno_solr_doc}#{solr_response_end}"))
      anno = Annotation.find_by_target_uri(sw_id).first
      assign(:annotation, anno)
      render
    end
    it_behaves_like "Annotation display"
  end
  
end
