class CourseReservesController < ApplicationController
  include Blacklight::Catalog::SearchContext
  include Blacklight::Configurable
  include Blacklight::SolrHelper
  include CourseReserves

  def index
    facet = "crez_course_info"
    p = {}
    p[:"facet.field"] = facet
    p[:"f.#{facet}.facet.limit"] = "-1"  # this implies lexical sort
    p[:rows] = 0
    response = find(p)
    course_reserves = []
    response.facets.first.items.each do |item|
      course_reserves << CourseInfo.new(item.value)
    end
    @course_reserves = course_reserves
  end
end
