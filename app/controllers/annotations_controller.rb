class AnnotationsController < ApplicationController
#  before_action :set_annotation, only: [:show]

  # GET /annotations/1
  # GET /annotations/1.json
  # returns annotation model objects for annos that have the searchworks solr doc id as a target
  def show
    @sw_doc_id = params[:id]
    # FIXME:  should probably be hardcoded or use hostname but depends on Triannon annos
    #target_uri = "http://#{Settings.HOSTNAME}.stanford.edu/view/#{@sw_doc_id}"
    target_uri = "#{Constants::CONTACT_INFO[:website][:url]}/view/#{@sw_doc_id}"
    annos = Annotation.find_by_target_uri(target_uri)
    @annotations = annos if annos.present?
  end

  # GET /annotations/new
  def new
    @annotation = Annotation.new({})
  end

  # POST /annotations
  # POST /annotations.json
  def create
    @annotation = Annotation.new(anno_params)
    target_sw_doc_id = anno_params['hasTarget']['id'] unless anno_params['hasTarget'].blank? || anno_params['hasTarget']['id'].blank?
    respond_to do |format|
      if @annotation.save(current_user.sunet, current_user.webauth_groups)
        msg = 'Annotation was successfully created. (You may need to refresh this page to see it.)'
        format.html { redirect_to annotation_path(target_sw_doc_id), notice: msg}
      else
        flash[:error] = "There was a problem creating the Annotation (for #{target_sw_doc_id}): #{@annotation.errors.full_messages if @annotation.errors.present?}"
        format.html { render :new, status: 500 }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
#    def set_annotation
#      @annotation = Annotation.find(params[:id])
#    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def anno_params
      params[:annotation]
    end
end
