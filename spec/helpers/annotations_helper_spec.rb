require 'spec_helper'

describe AnnotationsHelper, annos: true do
  context '#oa_motivations' do
    it 'returns Array of Strings' do
      expect(oa_motivations).to be_an Array
      expect(oa_motivations.first).to be_a String
    end
    it "doesn't return OA url prefix" do
      expect(oa_motivations.first).not_to match RDF::Vocab::OA.to_uri.to_s
    end
    it 'has OA motivation' do
      expect(oa_motivations.size).to be > 8
      expect(oa_motivations).to include "bookmarking"
      expect(oa_motivations).to include "commenting"
      expect(oa_motivations).to include "tagging"
    end
  end

  context "#tag_annos" do
    it 'returns Array of LD4L::OpenAnnotationRDF::TagAnnotation objects contained in passed Array' do
      annos = [LD4L::OpenAnnotationRDF::Annotation.new,
                LD4L::OpenAnnotationRDF::CommentAnnotation.new,
                LD4L::OpenAnnotationRDF::TagAnnotation.new,
                LD4L::OpenAnnotationRDF::CommentAnnotation.new,
                LD4L::OpenAnnotationRDF::TagAnnotation.new]
      assign(:annotations, annos)
      tag_annos = helper.tag_annos
      expect(tag_annos).to be_an Array
      expect(tag_annos.size).to eq 2
      tag_annos.each { |a| expect(a).to be_a LD4L::OpenAnnotationRDF::TagAnnotation }
    end
    it 'returns empty Array if there are no LD4L::OpenAnnotationRDF::TagAnnotation objects in the passed Array' do
      annos = [LD4L::OpenAnnotationRDF::Annotation.new,
                LD4L::OpenAnnotationRDF::CommentAnnotation.new,
                LD4L::OpenAnnotationRDF::CommentAnnotation.new,
                LD4L::OpenAnnotationRDF::Annotation.new]
      assign(:annotations, annos)
      expect(helper.tag_annos).to eq []
    end
    it 'returns an empty Array if it is passed an empty Array' do
      assign(:annotations, [])
      expect(helper.tag_annos).to eq []
    end
    it 'returns empty Array if it is passed nil' do
      assign(:annotations, nil)
      expect(helper.tag_annos).to eq []
    end
  end

  context "#comment_annos" do
    it 'returns Array of LD4L::OpenAnnotationRDF::CommentAnnotation objects contained in passed Array' do
      annos = [LD4L::OpenAnnotationRDF::Annotation.new,
                LD4L::OpenAnnotationRDF::CommentAnnotation.new,
                LD4L::OpenAnnotationRDF::TagAnnotation.new,
                LD4L::OpenAnnotationRDF::CommentAnnotation.new,
                LD4L::OpenAnnotationRDF::TagAnnotation.new]
      assign(:annotations, annos)
      comment_annos = helper.comment_annos
      expect(comment_annos).to be_an Array
      expect(comment_annos.size).to eq 2
      comment_annos.each { |a| expect(a).to be_a LD4L::OpenAnnotationRDF::CommentAnnotation }
    end
    it 'returns empty Array if there are no LD4L::OpenAnnotationRDF::CommentAnnotation objects in the passed Array' do
      annos = [LD4L::OpenAnnotationRDF::Annotation.new,
                LD4L::OpenAnnotationRDF::TagAnnotation.new,
                LD4L::OpenAnnotationRDF::Annotation.new]
      assign(:annotations, annos)
      expect(helper.comment_annos).to eq []
    end
    it 'returns an empty Array if it is passed an empty Array' do
      assign(:annotations, [])
      expect(helper.comment_annos).to eq []
    end
    it 'returns empty Array if it is passed nil' do
      assign(:annotations, nil)
      expect(helper.comment_annos).to eq []
    end
  end

end
