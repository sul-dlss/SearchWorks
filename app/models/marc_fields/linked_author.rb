# frozen_string_literal: true

##
# A class to parse MARC "author" fields that have hyperlinks for searching/display
# (i.e., href vs link/anchor) and post text for display (context).
#
# Initially, ported over from solrmarc-sw `author_corp_display`, `author_meeting_display`, and
# based in part on SearchWorks' `link_to_author_from_marc`
#
class LinkedAuthor < MarcField
  attr_reader :target

  def initialize(document, target)
    @document = document
    @target = target.to_sym
  end

  def to_partial_path
    'marc_fields/linked_author'
  end

  def i18n_key
    super + '.' + target.to_s
  end

  def values
    return {} unless document[:author_struct]

    document[:author_struct].first[target] || []
  end

  def present?
    values.present?
  end
end
