module AccessPanelHelper

  def link_to_course_reserve_course(course)
    link_to("#{course.id} -- #{course.name}", catalog_index_path({f: {course: [course.id], instructor: [course.instructor]}}))
  end

end
