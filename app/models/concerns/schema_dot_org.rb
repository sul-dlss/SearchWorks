# frozen_string_literal: true

module SchemaDotOrg
  def schema_dot_org?
    as_schema_dot_org.present?
  end

  def as_schema_dot_org
    Array(self[:schema_dot_org_struct]).first || solr_values_to_schema_dot_org
  end

  def solr_values_to_schema_dot_org
    @solr_values_to_schema_dot_org ||= begin
      {
        "@context": "http://schema.org",
        "@type": jsonld_itemtype,
        name: self[:title_display],
        author: (if self[:author_person_display]
            {
              "@type": 'Person',
              name: self[:author_person_display]
            }
          elsif self[:author_corp_display]
            {
              "@type": 'Organization',
              name: self[:author_corp_display]
            }
          elsif self[:author_meeting_display]
            {
              "@type": 'Organization',
              name: self[:author_meeting_display]
            }
          end)
      }.compact
    end
  end

  def jsonld_itemtype
    itemtype.sub('http://schema.org/', '')
  end

  # Override Blacklight's default itemtype with a more specific value
  def itemtype
    format = self[:format_main_ssim] || []
    genre = self[:genre_ssim] || []
    case
    when genre.include?('Thesis/Dissertation')
      'http://schema.org/Thesis'
    when genre.include?('Video games')
      'http://schema.org/VideoGame'
    when format.include?('Equipment')
      'http://schema.org/Thing'
    when format.include?('Book')
      'http://schema.org/Book'
    when format.include?('Dataset')
      'http://schema.org/Dataset'
    when format.include?('Image')
      'http://schema.org/ImageObject'
    when format.include?('Journal/Periodical')
      'http://schema.org/Periodical'
    when format.include?('Map')
      'http://schema.org/Map'
    when format.include?('Music recording')
      'http://schema.org/MusicRecording'
    when format.include?('Newspaper')
      'http://bib.schema.org/Newspaper'
    when format.include?('Software/Multimedia')
      'http://schema.org/SoftwareApplication'
    when format.include?('Sound recording')
      'http://schema.org/AudioObject'
    when format.include?('Video')
      'http://schema.org/VideoObject'
    else
      'http://schema.org/CreativeWork'
    end
  end
end
