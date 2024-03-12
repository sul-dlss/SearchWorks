# frozen_string_literal: true

module IndexAuthors
  def authors_from_index
    [self[:author_person_full_display], self[:vern_author_person_full_display],
     self[:author_corp_display], self[:vern_author_corp_display],
     self[:author_meeting_display], self[:vern_author_meeting_display]].flatten.compact.uniq
  end
end
