class SelectAllController < ApplicationController
  include Blacklight::Configurable
  copy_blacklight_config_from(CatalogController)

  def select
    current_or_guest_user.save! unless current_or_guest_user.persisted?
    if params['bookmarks'].present?
      success = params['bookmarks'].all? do |bookmark|
        bookmark = { document_id: bookmark, document_type: blacklight_config.solr_document_model.to_s }
        current_or_guest_user.bookmarks.where(bookmark).exists? || current_or_guest_user.bookmarks.create(bookmark) 
      end
    end
    respond_to do |format|
      format.json { render json: { bookmarks: { count: current_or_guest_user.bookmarks.count }, status: success } }
    end
  end

  def unselect
    current_or_guest_user.save! unless current_or_guest_user.persisted?
    if params['bookmarks'].present?
      success = params['bookmarks'].all? do |bookmark|
        bookmark = current_or_guest_user.bookmarks.where(document_id: bookmark, document_type: blacklight_config.solr_document_model.to_s).first
        bookmark && bookmark.delete && bookmark.destroyed?
      end
    end
    respond_to do |format|
      format.json { render json: { bookmarks: { count: current_or_guest_user.bookmarks.count }, status: success } }
    end
  end
end