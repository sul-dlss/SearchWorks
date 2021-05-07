class CourseReservesController < ApplicationController
  include Blacklight::Configurable
  include Blacklight::Searchable
  include CourseReserves
  copy_blacklight_config_from(CatalogController)

  def index
    facet = "crez_course_info"
    p = {}
    p[:"facet.field"] = facet
    p[:"f.#{facet}.facet.limit"] = "-1"  # this implies lexical sort
    p[:rows] = 0
    response = repository.search(p)
    course_reserves = []
    response.aggregations.values.first.items.each do |item|
      course_reserves << CourseInfo.new(item.value)
    end
    @course_reserves = course_reserves
  end

  delegate :repository, to: :blacklight_config
end
