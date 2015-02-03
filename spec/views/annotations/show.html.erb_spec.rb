require 'spec_helper'

describe "annotations/show" do
  before(:each) do
    @comment_triannon_id = "5051575d-6248-4ff4-a163-8cc6d59785f3"
    comment_jsonld = '{
                      "@context": {
                        "content": "http://www.w3.org/2011/content#",
                        "dc": "http://purl.org/dc/terms/",
                        "dcmitype": "http://purl.org/dc/dcmitype/",
                        "openannotation": "http://www.w3.org/ns/oa#"
                      },
                      "@graph": [
                        {
                          "@id": "_:g70171578915160",
                          "@type": [
                            "dcmitype:Text",
                            "content:ContentAsText"
                          ],
                          "content:chars": "I am a comment!",
                          "dc:format": "text/plain"
                        },
                        {
                          "@id": "https://triannon-dev.stanford.edu/annotations/5051575d-6248-4ff4-a163-8cc6d59785f3",
                          "@type": "openannotation:Annotation",
                          "openannotation:annotatedAt":{
                            "@value":"2015-02-02T13:11:05Z","@type":"xsd:dateTime"
                          },
                          "openannotation:hasBody": {
                            "@id": "_:g70171578915160"
                          },
                          "openannotation:hasTarget": {
                            "@id": "http://searchworks.stanford.edu/view/666"
                          },
                          "openannotation:motivatedBy": {
                            "@id": "openannotation:commenting"
                          }
                        }
                      ]
                    }'
    comment_resp = double("resp")
    allow(comment_resp).to receive(:body).and_return(comment_jsonld)
    comment_conn = double("oa_rsolr_conn")
    allow(comment_conn).to receive(:get).and_return(comment_resp)
    allow(Annotation).to receive(:oa_rsolr_conn).and_return(comment_conn)
    @comment_anno = Annotation.find_by_target_uri(@comment_triannon_id).first
    @anno_triannon_id = "2155d7f5-cd79-435f-ab86-11f1e246d3ce"
    tag_jsonld = '{
                  "@context": {
                    "content": "http://www.w3.org/2011/content#",
                    "dc": "http://purl.org/dc/terms/",
                    "dcmitype": "http://purl.org/dc/dcmitype/",
                    "openannotation": "http://www.w3.org/ns/oa#"
                  },
                  "@graph": [
                    {
                      "@id": "_:g70171583104620",
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
                      "openannotation:annotatedAt":{
                        "@value":"2015-02-02T01:01:01Z","@type":"xsd:dateTime"
                      },
                      "openannotation:hasBody": {
                        "@id": "_:g70171583104620"
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
    anno_resp = double("resp")
    allow(anno_resp).to receive(:body).and_return(tag_jsonld)
    anno_conn = double("oa_rsolr_conn")
    allow(anno_conn).to receive(:get).and_return(anno_resp)
    allow(Annotation).to receive(:oa_rsolr_conn).and_return(anno_conn).at_least(:once)
    @tag_anno = Annotation.find_by_target_uri(@anno_triannon_id).first
    @semantic_tag_triannon_id = "31e9e5ea-085a-43d7-83f3-b586b3c5783f"
    st_jsonld = '{
                "@context": {
                  "openannotation": "http://www.w3.org/ns/oa#"
                },
                "@graph": [
                  {
                    "@id": "http://dbpedia.org/resource/Love",
                    "@type": "openannotation:SemanticTag"
                  },
                  {
                    "@id": "https://triannon-dev.stanford.edu/annotations/31e9e5ea-085a-43d7-83f3-b586b3c5783f",
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
    st_resp = double("resp")
    allow(st_resp).to receive(:body).and_return(st_jsonld)
    st_conn = double("oa_rsolr_conn")
    allow(st_conn).to receive(:get).and_return(st_resp)
    allow(Annotation).to receive(:oa_rsolr_conn).and_return(st_conn)
    @semantic_tag_anno = Annotation.find_by_target_uri(@semantic_tag_triannon_id).first
  end
  
  shared_examples_for 'Annotation display' do
    it "triannon id" do
      expect(rendered).to match /<a href="https:\/\/triannon-dev.stanford.edu\/annotations\//
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
      assign(:annotation, @comment_anno)
      render
    end
    it_behaves_like "Annotation display"
    it "comment annotation model" do
      expect(rendered).to match /LD4L::OpenAnnotationRDF::CommentAnnotation/
    end
    it "content" do
      expect(rendered).to match /content: /
    end
    it "format" do
      expect(rendered).to match /format: /
      expect(rendered).to match /text\/plain/
    end
    it "shouldn't display phantom blank nodes for bodies" do
      # view gets [], [], ...
      expect(rendered).not_to match /\[\],/
      assign(:annotation, @tag_anno)
      render
      expect(rendered).not_to match /\[\],/
    end
  end
  
  describe 'TagAnnotation' do
    before(:each) do
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
      assign(:annotation, @semantic_tag_anno)
      render
    end
    it_behaves_like "Annotation display"
    it "semantic tag annotation model" do
      expect(rendered).to match /LD4L::OpenAnnotationRDF::SemanticTagAnnotation/
    end
  end

  describe 'unrecognized Annotation model' do
    before(:each) do
      unrec_model_id = "e8b3ecdc-d8da-4b85-944d-65d800493bce"
      assign(:annotation, Annotation.find_by_target_uri(unrec_model_id).first)
      render
    end
    it_behaves_like "Annotation display"
  end
  
end
