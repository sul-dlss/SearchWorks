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

      def selected_databases_index_access_points
        :selected_databases
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
