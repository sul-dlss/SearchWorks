# encoding: UTF-8

module RecordHelper
  ##
  # Sugar around changes now in mods_display that utilizes previous SearchWorks
  # RecordHelper behavior
  def linked_mods_subjects(subjects)
    subjects.map do |subject|
      mods_subject_field(subject) do |subject_text, buffer|
        link_to(
          subject_text,
          search_catalog_path(
            q: "\"#{[buffer, subject_text.strip].flatten.join(' ')}\"",
            search_field: 'subject_terms'
          )
        )
      end
    end.join('').html_safe
  end

  ##
  # Sugar around changes now in mods_display that utilizes previous SearchWorks
  # RecordHelper behavior
  def linked_mods_genres(genres)
    genres.map do |subject|
      mods_genre_field(subject) do |subject_text, buffer|
        link_to(
          subject_text,
          search_catalog_path(
            q: "\"#{[buffer, subject_text.strip].flatten.join(' ')}\"",
            search_field: 'subject_terms'
          )
        )
      end
    end.join('').html_safe
  end

  ##
  # Expose format_mods_html from mods_display to properly encode content as needed
  # RecordHelper behavior
  def format_record_html(record_content)
    format_mods_html(record_content, field: ModsDisplay::Values.new(field: ModsDisplay::Contents.new(nil)))
  end
end
