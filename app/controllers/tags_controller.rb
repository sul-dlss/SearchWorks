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
    @tag = Tag.new({})
  end

  # POST /tags
  # POST /tags.json
  def create
    @tag = Tag.new(tag_params)

    respond_to do |format|
      if @tag.save
        format.html { redirect_to @tag, status: :created, notice: 'Tag was successfully created.' }
        format.json { render :show, status: :created, location: @tag }
      else
        flash[:alert] = 'There was a problem creating the Tag.'
        format.html { render :new, status: 500 }
        format.json { render json: @tag.errors, status: 500 }
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
