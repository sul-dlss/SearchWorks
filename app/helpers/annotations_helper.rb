module AnnotationsHelper

  # @return [Array<String>] the allowed motivations from the OpenAnnotation spec, without the URL prefix
  def oa_motivations
  	@@oa_motivations ||= begin
      motivations = RDF::Vocab::OA.properties.find_all { |prop| prop.type.include?(RDF::Vocab::OA.Motivation) }
      motivations.map! { |u| u.to_s.sub(RDF::Vocab::OA.to_uri.to_s, '')}
    end
  end

  # @return [Array<LD4L::OpenAnnotationRDF::TagAnnotation>] Array containing only the TagAnnotation objects from @annotations
  def tag_annos
    return [] unless @annotations.present?
    @annotations.select { |anno| anno.instance_of?(LD4L::OpenAnnotationRDF::TagAnnotation) }
  end

  # @return [Array<LD4L::OpenAnnotationRDF::CommentAnnotation>] Array containing only the CommentAnnotation objects from @annotations
  def comment_annos
    return [] unless @annotations.present?
    @annotations.select { |anno| anno.instance_of?(LD4L::OpenAnnotationRDF::CommentAnnotation) }
  end

end
