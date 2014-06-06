module ApplicationHelper

  def render_search_bar_advanced_widget
    render partial:'catalog/search_bar_advanced_widget'
  end

  def render_search_bar_browse_widget
    render partial: 'catalog/search_bar_browse_widget'
  end

  def render_search_bar_selections_widget
    render partial: 'catalog/search_bar_selections_widget'
  end

  def render_search_targets_widget
    render partial: 'catalog/search_targets_widget'
  end

  def get_data_with_label(doc, label, field_string)
    items = []
    if doc[field_string]
      fields = doc[field_string]
      if fields.is_a?(Array)
          fields.each do |field|
            items << field
          end
      else
        items << fields
      end
    end
    return {:label=>label,:fields=>items,:vernacular=>get_indexed_vernacular(doc,field_string)} unless items.empty?
  end
  # Generate a dt/dd pair with a link with a label given a field in the SolrDocument
  def link_to_data_with_label(doc,label,field_string,url)
    items = []
    vern = []
    fields = get_data_with_label(doc,label,field_string)
    unless fields.nil?
      unless fields[:fields].nil?
        fields[:fields].each do |field|
          items << link_to(field,url.merge!(:q => "\"#{field}\""))
        end
      end
      unless fields[:vernacular].nil?
        fields[:vernacular].each do |field|
          vern << link_to(field,url.merge!(:q => "\"#{field}\""))
        end
      end
    end
    return {:label=>label,:fields=>items,:vernacular=>vern} unless (items.empty? and vern.empty?)
  end
  def get_indexed_vernacular(doc,field)
    fields = []
    if doc["vern_#{field}"]
      vern_fields = doc["vern_#{field}"]
      if vern_fields.is_a?(Array)
        vern_fields.each do |vern_field|
          fields << vern_field
        end
      else
        fields << vern_fields
      end
    end
    return fields unless fields.empty?
  end
end
