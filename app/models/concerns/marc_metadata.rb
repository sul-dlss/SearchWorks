# frozen_string_literal: true

##
# A mixin to include MarcField subclasses into the SolrDocument
module MarcMetadata
  def marc_field(tag_or_specialization, **kwargs)
    return public_send(tag_or_specialization, **kwargs) if tag_or_specialization.is_a?(Symbol)

    MarcField.new(self, Array.wrap(tag_or_specialization).map(&:to_s), **kwargs)
  end

  def awards
    @awards ||= Awards.new(self)
  end

  def linked_series
    @linked_series ||= LinkedSeries.new(self)
  end

  def unlinked_series
    @unlinked_series ||= UnlinkedSeries.new(self)
  end

  def language
    @language ||= Language.new(self)
  end

  def linked_author(target)
    @linked_author = {} if @linked_author.blank?
    @linked_author[target] ||= LinkedAuthor.new(self, target)
  end

  def linked_related_works
    @linked_related_works ||= LinkedRelatedWorks.new(self)
  end

  def database_note
    @database_note ||= DatabaseNote.new(self)
  end

  def production_notice
    @production_notice ||= ProductionNotice.new(self)
  end

  def marc_instrumentation
    return unless respond_to?(:to_marc)

    @marc_instrumentation ||= Instrumentation.new(self)
  end

  def added_entry
    @added_entry ||= AddedEntry.new(self)
  end

  def local_subjects
    @local_subjects ||= LocalSubjects.new(self)
  end

  def issn
    @issn ||= Issn.new(self)
  end

  def doi
    @doi ||= Doi.new(self)
  end

  def isbn
    @isbn ||= Isbn.new(self)
  end

  def linked_serials
    @linked_serials ||= LinkedSerials.new(self)
  end

  def included_works
    @included_works ||= IncludedWorks.new(self)
  end

  def linked_collection
    @linked_collection ||= LinkedCollection.new(self)
  end
end
