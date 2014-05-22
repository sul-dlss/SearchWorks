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
          format_param = @params[:f][:format] || @params[:f][:format_main_ssim]
          if format_param
            case
            when format_param.include?("Database")
              :databases
            end
          end
        end
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
