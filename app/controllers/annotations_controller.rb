class AnnotationsController < ApplicationController
#  before_action :set_annotation, only: [:show]

  # GET /annotations
  # GET /annotations.json
  def index
    # TODO:  need to implement Annotation.all
    @annotations = Annotation.all
  end

  # GET /annotations/1
  # GET /annotations/1.json
  # displays the FIRST annotation;  annotations that have match the searchworks record as a target are retrieved
  def show
    # FIXME:  should probably be hardcoded or use hostname but depends on Triannon annos
    #target_uri = "http://#{Settings.HOSTNAME}.stanford.edu/view/#{params[:id]}"
    target_uri = "#{Constants::CONTACT_INFO[:website][:url]}/view/#{params[:id]}"
    annos = Annotation.find_by_target_uri(target_uri)
    # TODO:  need to render all of 'em that match, not just first one
    @annotation = annos.first
    # TODO:  need to render template based on model type
  end

  # GET /annotations/new
  def new
    @annotation = Annotation.new({})
  end

  # POST /annotations
  # POST /annotations.json
  def create
    @annotation = Annotation.new(anno_params)

    respond_to do |format|
      if @annotation.save
        format.html { redirect_to @annotation, status: :created, notice: 'Annotation was successfully created.' }
        format.json { render :show, status: :created, location: @annotation }
      else
        flash[:alert] = 'There was a problem creating the Annotation.'
        format.html { render :new, status: 500 }
        format.json { render json: @annotation.errors, status: 500 }
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
