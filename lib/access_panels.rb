class AccessPanels
  def initialize(document)
    @document = document
  end

  private

  def method_missing(method_name, *args, &block)
    case method_name
    when /(\w*)\?$/
      send(method_name.to_s[0...-1].to_sym).present?
    else
      begin
        AccessPanels.const_get(method_name.to_s.classify).new(@document)
      rescue NameError
        super
      end
    end
  end
end
