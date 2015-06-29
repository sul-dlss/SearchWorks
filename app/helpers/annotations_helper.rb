module AnnotationsHelper

  # @return [Array<String>] the allowed motivations from the OpenAnnotation spec, without the URL prefix
  def oa_motivations
  	@@oa_motivations ||= begin
      motivations = RDF::Vocab::OA.properties.find_all { |prop| prop.type.include?(RDF::Vocab::OA.Motivation) }
      motivations.map! { |u| u.to_s.sub(RDF::Vocab::OA.to_uri.to_s, '')}
    end
  end
end
