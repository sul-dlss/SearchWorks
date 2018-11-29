module AccessPanelHelper
  def link_to_course_reserve_course(course)
    link_to("#{course.id} -- #{course.name}", search_catalog_path({ f: { course: [course.id], instructor: [course.instructor] } }))
  end

  def link_to_library_header(library)
    link_to_unless(Constants::LIBRARY_ABOUT[library.code].nil?, render(:partial => 'catalog/access_panels/library', locals: { :library => library }), Constants::LIBRARY_ABOUT[library.code])
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
