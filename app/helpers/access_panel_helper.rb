module AccessPanelHelper

  def link_to_course_reserve_course(course)
    link_to("#{course.id} -- #{course.name}", catalog_index_path({f: {course: [course.id], instructor: [course.instructor]}}))
  end

  def link_to_library(library)
    link_to_unless(Constants::LIBRARY_ABOUT[library.code].nil?, library.name, Constants::LIBRARY_ABOUT[library.code])
  end

  def thumb_for_library(library)
    image_name = if library.zombie?
      "#{library.code}.png"
    else
      "#{library.code}.jpg"
    end
    image_tag(image_name, class: "pull-left", alt: "", height: 50)
  end

end
