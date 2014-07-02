module SearchWorks
  class PageLocation
    def initialize(params={})
      @params = params
    end
    def access_point
      @access_point ||= AccessPoints.new(@params)
    end
    def access_point?
      access_point.to_s.present?
    end
    private
    class AccessPoints
      def initialize(params={})
        @params = params
      end
      def point
        self.send(:"#{@params[:controller]}_#{@params[:action]}_access_points")
      end
      def name
        to_s.gsub(/_/, ' ').capitalize.pluralize
      end
      def to_s
        point.to_s
      end
      def catalog_index_access_points
        if @params[:f]
          if format_includes_databases?
            return :databases
          end
          if course_reserve_parameters?
            return :course_reserve
          end
          if collection_parameters?
            return :collection
          end
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
        @params[:f][:collection].present? && !@params[:f][:collection].include?("sirsi")
      end

      def selected_databases_index_access_points
        :selected_databases
      end

      def browse_index_access_points
        if @params[:start]
          return :callnumber_browse
        end
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
