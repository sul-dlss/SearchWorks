# frozen_string_literal: true

module SelectionsCount
  def selections_counts
    @selections_counts ||= Struct.new(:catalog, :articles).new(
      current_or_guest_user.bookmarks.where(record_type: 'catalog').count,
      current_or_guest_user.bookmarks.where(record_type: 'article').count
    )
  end
end
