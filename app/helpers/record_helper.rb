# encoding: UTF-8
module RecordHelper
  def display_content_field(field)
    if field.respond_to?(:label, :values) &&
       field.values.any?(&:present?)
      display_content_label(field.label) +
        display_content_values(field.values)
    end
  end

  def display_content_label(label)
    content_tag :dt, label
  end

  def display_content_values(values)
    values.map do |value|
      content_tag :dd, value
    end.join('').html_safe
  end

  def mods_display_label(label)
    content_tag(:dt, label.delete(':'))
  end

  def mods_display_content(values, delimiter = nil)
    if delimiter
      content_tag(:dd, values.map do|value|
        link_urls_and_email(value) if value.present?
      end.compact.join(delimiter).html_safe)
    else
      Array[values].flatten.map do |value|
        content_tag(:dd, link_urls_and_email(value).html_safe) if value.present?
      end.join.html_safe
    end
  end

  def mods_record_field(field, delimiter = nil)
    if field.respond_to?(:label, :values) &&
       field.values.any?(&:present?)
      mods_display_label(field.label) +
        mods_display_content(field.values, delimiter)
    end
  end

  def mods_name_field(field)
    if field.respond_to?(:label, :values) &&
       field.values.any?(&:present?)
      mods_display_label(field.label) +
        mods_display_name(field.values)
    end
  end

  def mods_primary_names(names)
    names.map do |name|
      if author_creator_label?(name.label)
        name
      elsif names_include_primary?(name)
        OpenStruct.new(label: name.label, values: name.values.select { |n| roles_include_primary?(n) })
      end
    end.compact
  end

  def mods_secondary_names(names)
    names.map do |name|
      if !author_creator_label?(name.label) && names_include_secondary?(name)
        OpenStruct.new(label: name.label, values: name.values.reject { |n| roles_include_primary?(n) })
      end
    end.compact
  end

  def mods_display_name(names)
    names.map do |name|
      content_tag(:dd) do
        "#{link_to(name.name, catalog_index_path(q: "\"#{name.name}\"", search_field: 'search_author'))}#{" (#{name.roles.join(', ')})" if name.roles.present?}".html_safe
      end
    end.join.html_safe
  end

  def mods_subject_field(subjects)
    if subjects.any?(&:values)
      subjects.map do |subject_field|
        subject_field.values.map do |subject_line|
          "<dd>#{link_mods_subjects(subject_line).join(' &gt; ')}</dd>"
        end.join('')
      end.join('').html_safe
    end
  end

  def mods_genre_field(genres)
    if genres.any?(&:values)
      genres.map do |genre_field|
        genre_field.values.map do |genre_line|
          "<dd>#{link_mods_genres(genre_line)}</dd>"
        end.join('')
      end.join('').html_safe
    end
  end

  def link_mods_genres(genre)
    link_buffer = []
    link_to_mods_subject(genre, link_buffer)
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
    email = %r{[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|asia|jobs|museum)\b}i
    matches = [val.scan(url), val.scan(email)].flatten.uniq
    unless val =~ /<a/ # we'll assume that linking has alraedy occured and we don't want to double link
      matches.each do |match|
        val = if match =~ email
                val.gsub(match, "<a href='mailto:#{match}'>#{match}</a>")
              else
                val.gsub(match, "<a href='#{match}'>#{match}</a>")
        end
      end
    end
    val
  end

  private

  def author_creator_label?(label)
    label =~ %r{author/creator:?}i
  end

  def names_include_primary?(names)
    names.values.any? do |name|
      roles_include_primary?(name)
    end
  end

  def names_include_secondary?(names)
    names.values.any? do |name|
      !roles_include_primary?(name)
    end
  end

  def roles_include_primary?(name)
    return unless name.roles.present?
    name.roles.include?('Author') || name.roles.include?('Creator')
  end
end
