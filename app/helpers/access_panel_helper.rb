module AccessPanelHelper

  def link_to_course_reserve_course(course)
    link_to("#{course.id} -- #{course.name}", catalog_index_path({f: {course: [course.id], instructor: [course.instructor]}}))
  end

  def link_to_library(library_abbr)
    link_to("#{Constants::LIB_TRANSLATIONS[library_abbr]}", "http://library.stanford.edu/libraries/#{library_abbr}/about")
  end

  def thumb_for_library(library_abbr)
    image_tag("#{library_abbr}.jpg", class: "pull-left", alt: Constants::LIB_TRANSLATIONS[library_abbr])
  end

end
