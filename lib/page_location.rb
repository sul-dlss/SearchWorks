module SearchWorks
  class PageLocation
    def initialize(params = {})
      @params = params
    end

    def access_point
      return unless @params[:f] && @params[:controller] == 'catalog' && @params[:action] == 'index'

      @access_point ||= case
                        when format_includes_databases?
                          :databases
                        when course_reserve_parameters?
                          :course_reserve
                        when collection_parameters?
                          :collection
                        when digital_collections_parameters?
                          :digital_collections
                        when sdr_parameters?
                          :sdr
                        when dissertation_theses_parameters?
                          :dissertation_theses
                        when bookplate_fund_parameters?
                          :bookplate_fund
                        when government_documents_parameters?
                          :government_documents
                        when iiif_resources_parameters?
                          :iiif_resources
                        else
                          ''
                        end

      @access_point.presence
    end

    def access_point?
      access_point.present?
    end

    def databases?
      access_point == :databases
    end

    def sdr?
      access_point == :sdr
    end

    def collection?
      access_point == :collection
    end

    private

    def format_includes_databases?
      (@params[:f][:format] || @params[:f][:format_main_ssim])&.include?('Database')
    end

    def course_reserve_parameters?
      @params[:f][:course].present? && @params[:f][:instructor].present?
    end

    def collection_parameters?
      @params[:f][:collection].present? && !@params[:f][:collection].include?('sirsi')
    end

    def digital_collections_parameters?
      @params[:f][:collection_type]&.include?('Digital Collection')
    end

    def sdr_parameters?
      @params[:f][:building_facet]&.include?('Stanford Digital Repository')
    end

    def dissertation_theses_parameters?
      @params[:f][:genre_ssim]&.include?('Thesis/Dissertation')
    end

    def bookplate_fund_parameters?
      @params[:f][:fund_facet].present?
    end

    def government_documents_parameters?
      @params[:f][:genre_ssim]&.include?('Government document')
    end

    def iiif_resources_parameters?
      @params[:f][:iiif_resources]&.include?('available')
    end
  end
end
