module TagsHelper
  
  # @return [Array<String>] the allowed motivations from the OpenAnnotation spec, without the URL prefix
  def oa_motivations
  	@@oa_motivations ||= begin
      motivations = RDF::OpenAnnotation.properties.find_all { |prop| prop.type.include?(RDF::OpenAnnotation.Motivation) }
      motivations.map! { |u| u.to_s.sub(RDF::OpenAnnotation.to_uri.to_s, '')}
    end
  end
end
