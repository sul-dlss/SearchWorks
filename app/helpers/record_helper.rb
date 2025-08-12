# frozen_string_literal: true

module RecordHelper
  ##
  # Sugar around changes now in mods_display that utilizes previous SearchWorks
  # RecordHelper behavior
  def linked_mods_subjects(subjects)
    divs = subjects.map do |subject|
      dt_dd = mods_subject_field(subject) do |subject_text, buffer|
        link_to(
          subject_text,
          search_catalog_path(
            q: "\"#{[buffer, subject_text.strip].flatten.join(' ')}\"",
            search_field: 'subject_terms'
          )
        )
      end

      tag.div dt_dd, class: 'my-2', data: { controller: 'list-toggle', 'list-toggle-target': 'group' }
    end

    safe_join divs
  end

  ##
  # Sugar around changes now in mods_display that utilizes previous SearchWorks
  # RecordHelper behavior
  def linked_mods_genres(genres)
    divs = genres.map do |subject|
      dt_dd = mods_genre_field(subject) do |subject_text, buffer|
        link_to(
          subject_text,
          search_catalog_path(
            q: "\"#{[buffer, subject_text.strip].flatten.join(' ')}\"",
            search_field: 'subject_terms'
          )
        )
      end

      tag.div dt_dd, class: 'my-2', data: { controller: 'list-toggle', 'list-toggle-target': 'group' }
    end

    safe_join divs
  end

  ##
  # Expose format_mods_html from mods_display to properly encode content as needed
  # RecordHelper behavior
  def format_record_html(record_content)
    format_mods_html(record_content, field: ModsDisplay::Values.new(field: ModsDisplay::Contents.new(nil)))
  end
end
