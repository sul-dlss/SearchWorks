module SearchWorks
  class PageLocation
    def initialize(params = {})
      @params = params
    end

    def access_point
      @access_point ||= AccessPoints.new(@params)
    end

    def access_point?
      access_point.to_s.present?
    end

    class AccessPoints
      delegate :to_s, to: :point
      def initialize(params = {})
        @params = params
      end

      def point
        send(:"#{@params[:controller]}_#{@params[:action]}_access_points")
      end

      def name
        to_s.gsub(/_/, ' ').capitalize.pluralize
      end

      def catalog_index_access_points
        return unless @params[:f]

        case
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
        end
      end

      def format_parameter
        @params[:f][:format] || @params[:f][:format_main_ssim]
      end

      def format_includes_databases?
        format_parameter.include?('Database') if format_parameter
      end

      def course_reserve_parameters?
        @params[:f][:course].present? && @params[:f][:instructor].present?
      end

      def collection_parameters?
        @params[:f][:collection].present? && !@params[:f][:collection].include?('sirsi')
      end

      def digital_collections_parameters?
        (@params[:f][:collection_type] || []).include?('Digital Collection')
      end

      def sdr_parameters?
        (@params[:f][:building_facet] || []).include?('Stanford Digital Repository')
      end

      def dissertation_theses_parameters?
        (@params[:f][:genre_ssim] || []).include?('Thesis/Dissertation')
      end

      def bookplate_fund_parameters?
        @params[:f][:fund_facet].present?
      end

      def government_documents_parameters?
        (@params[:f][:genre_ssim] || []).include?('Government document')
      end

      def iiif_resources_parameters?
        (@params[:f][:iiif_resources] || []).include?('available')
      end

      def course_reserves_index_access_points
        :course_reserves
      end

      def browse_index_access_points
        return unless @params[:start]

        :callnumber_browse
      end

      def method_missing(method_name, *args, &block)
        case method_name
        when /(\w*)\?$/
          $1 == point.to_s
        when /_access_points$/
          nil
        else
          super
        end
      end
    end
  end
end
