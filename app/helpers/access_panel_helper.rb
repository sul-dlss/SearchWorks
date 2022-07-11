module AccessPanelHelper
  def link_to_course_reserve_course(course)
    link_to("#{course.id} -- #{course.name}", search_catalog_path({ f: { course: [course.id], instructor: [course.instructor] } }))
  end

  def link_to_library_header(library)
    link_to_unless(Constants::LIBRARY_ABOUT[library.code].nil?, render(partial: 'catalog/access_panels/library', locals: { library: library }), Constants::LIBRARY_ABOUT[library.code])
  end

  def thumb_for_library(library)
    image_name = if library.zombie?
      "#{library.code}.png"
    else
      "#{library.code}.jpg"
    end
    image_tag(image_name, class: "pull-left", alt: "", height: 50)
  rescue Sprockets::Rails::Helper::AssetNotFound => e
    Honeybadger.notify(e, error_message: "Missing library thumbnail for #{library.code}")

    nil
  end

  def display_connection_problem_links?(document)
    return true if document.access_panels.sfx?
    return true if document.access_panels.online? && document.is_a_database?

    document.access_panels.online? && document.access_panels.online.links.any?(&:stanford_only?)
  end
end
