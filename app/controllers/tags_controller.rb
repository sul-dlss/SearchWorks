class TagsController < ApplicationController
  before_action :set_tag, only: [:show]

  # GET /tags
  # GET /tags.json
  def index
    # TODO:  need to implement Tag.all
    @tags = Tag.all
  end

  # GET /tags/1
  # GET /tags/1.json
  def show
    # TODO:  need to implement show action
  end

  # GET /tags/new
  def new
    @tag = Tag.new
  end

  # POST /tags
  # POST /tags.json
  def create
    @tag = Tag.new(tag_params)
    @tag.motivatedBy << RDF::URI.new(RDF::OpenAnnotation.to_uri.to_s + tag_params["motivatedBy"]) if tag_params["motivatedBy"]
    # TODO: target will autofill from SW as IRI from OCLC number, OCLC work number, Stanford purl page, etc.
    # TODO: it should be possible to have multiple targets
    @tag.hasTarget << RDF::URI.new(Constants::CONTACT_INFO[:website][:url] + "/view/" + tag_params["hasTarget"]["id"]) if tag_params["hasTarget"]
    # TODO: body should be turned into appropriate text as blank node stuff
    @tag.hasBody << tag_params["hasBody"]
    @tag.annotatedAt << DateTime.now
    # TODO: annotatedBy - from WebAuth

    respond_to do |format|
      if @tag.save
        format.html { redirect_to @tag, notice: 'Tag was successfully created.' }
        format.json { render :show, status: :created, location: @tag }
      else
        format.html { render :new }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = Tag.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tag_params
      params[:tag]
    end
end
