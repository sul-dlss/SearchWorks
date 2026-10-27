# frozen_string_literal: true

module SchemaDotOrg
  def schema_dot_org?
    as_schema_dot_org.present?
  end

  # The indexer produces schema_dot_org_struct for geo objects.
  # See https://github.com/sul-dlss/SearchWorks/issues/2041
  def as_schema_dot_org
    Array(self[:schema_dot_org_struct]).first || solr_values_to_schema_dot_org
  end

  def solr_values_to_schema_dot_org
    @solr_values_to_schema_dot_org ||= {
      '@context': "http://schema.org",
      '@type': jsonld_itemtype,
      name: self[:title_display],
      author: (if self[:author_person_display]
                 {
                   '@type': 'Person',
                   name: self[:author_person_display]
                 }
               elsif self[:author_corp_display]
                 {
                   '@type': 'Organization',
                   name: self[:author_corp_display]
                 }
               elsif self[:author_meeting_display]
                 {
                   '@type': 'Organization',
                   name: self[:author_meeting_display]
                 }
               end)
    }.compact
  end

  def jsonld_itemtype
    itemtype.sub('http://schema.org/', '')
  end

  # Override Blacklight's default itemtype with a more specific value
  def itemtype
    format = self[:format_hsim] || []
    genre = self[:genre_ssim] || []
    if genre.include?('Thesis/Dissertation')
      'http://schema.org/Thesis'
    elsif genre.include?('Video games')
      'http://schema.org/VideoGame'
    elsif format.include?('Equipment')
      'http://schema.org/Thing'
    elsif format.include?('Book')
      'http://schema.org/Book'
    elsif format.include?('Dataset')
      'http://schema.org/Dataset'
    elsif format.include?('Image')
      'http://schema.org/ImageObject'
    elsif format.include?('Journal/Periodical')
      'http://schema.org/Periodical'
    elsif format.include?('Map')
      'http://schema.org/Map'
    elsif format.include?('Music recording')
      'http://schema.org/MusicRecording'
    elsif format.include?('Newspaper')
      'http://bib.schema.org/Newspaper'
    elsif format.include?('Software/Multimedia')
      'http://schema.org/SoftwareApplication'
    elsif format.include?('Sound recording')
      'http://schema.org/AudioObject'
    elsif format.include?('Video')
      'http://schema.org/VideoObject'
    else
      'http://schema.org/CreativeWork'
    end
  end
end
