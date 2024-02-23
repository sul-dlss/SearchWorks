# The facet value here is a UUID for a folio course.  We overide to show a label that a user
# can read.
class FolioCourseFacetItemPresenter < Blacklight::FacetItemPresenter
  def constraint_label
    CourseReserve.find(value)&.course_number || value
  end
end
