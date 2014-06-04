# encoding: UTF-8
module RecordHelper
  def mods_display_label label
    content_tag(:dt, label.gsub(":",""))
  end

  def mods_display_content content
    content_tag(:dd, link_urls_and_email(content).html_safe)
  end

  def mods_record_field field
    if field.respond_to?(:label, :values) &&
       field.values.any?(&:present?)
      mods_display_label(field.label) +
      mods_display_content(field.values.join)
    end
  end

  def mods_name_field(field)
    if field.respond_to?(:label, :values) &&
       field.values.any?(&:present?)
      mods_display_label(field.label) +
      mods_display_name(field.values)
    end
  end

  def mods_display_name(names)
    content_tag(:dd) do
      names.map do |name|
        "#{link_to(name.name, catalog_index_path(q: "\"#{name.name}\"", search_field: 'search_author'))}#{" (#{name.roles.join(', ')})" if name.roles.present?}"
      end.join('<br/>').html_safe
    end
  end

  def mods_subject_field(subjects)
    if subjects.any?(&:values)
      subjects.map do |subject_field|
        subject_field.values.map do |subject_line|
          link_mods_subjects(subject_line).join(" &gt; ")
        end.join('<br/>')
      end.join('<br/>').html_safe
    end
  end

  def link_mods_subjects(subjects)
    link_buffer = []
    linked_subjects = []
    subjects.each do |subject|
      if subject.present?
        linked_subjects << link_to_mods_subject(subject, link_buffer)
      end
    end
    linked_subjects
  end

  def link_to_mods_subject(subject, buffer)
    subject_text = subject.respond_to?(:name) ? subject.name : subject
    link = link_to(
      subject_text,
      catalog_index_path(
        q: "\"#{[buffer, subject_text.strip].flatten.join(' ')}\"",
        search_field: 'subject_terms'
      )
    )
    buffer << subject_text.strip
    link << " (#{subject.roles.join(', ')})" if subject.respond_to?(:roles) && subject.roles.present?
    link
  end

  def link_urls_and_email(val)
    val = val.dup
    # http://daringfireball.net/2010/07/improved_regex_for_matching_urls
    url = /(?i)\b(?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\([^\s()<>]+|\([^\s()<>]+\)*\))+(?:\([^\s()<>]+|\([^\s()<>]+\)*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’])/i
    # http://www.regular-expressions.info/email.html
    email = /[A-Z0-9_\.%\+\-\']+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,4}|museum|travel)/i
    matches = [val.scan(url), val.scan(email)].flatten
    unless val =~ /<a/ # we'll assume that linking has alraedy occured and we don't want to double link
      matches.each do |match|
        if match =~ email
          val = val.gsub(match, "<a href='mailto:#{match}'>#{match}</a>")
        else
          val = val.gsub(match, "<a href='#{match}'>#{match}</a>")
        end
      end
    end
    val
  end
end
