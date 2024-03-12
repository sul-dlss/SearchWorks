# frozen_string_literal: true

module BookmarksHelper
  def bookmarks?
    %w[bookmarks article_selections].include? params[:controller]
  end

  #Similar to BL page_entries_info /app/helpers/blacklight/catalog_helper_behavior.rb
  def current_entries_info collection, options = {}
    end_num = if collection.respond_to? :groups and render_grouped_response? collection
      collection.groups.length
    else
      collection.limit_value
    end

    end_num = [collection.offset_value + end_num, collection.total_count].min
    begin_num = if collection.total_count == 0
      0
    else
      collection.offset_value + 1
    end
    "#{begin_num} - #{end_num}"
  end
end
