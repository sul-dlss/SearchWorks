module ApplicationHelper
  # This is a path helper that routes the main search
  # form based on the current search context.
  def searchworks_search_action_path(opts = {})
    return articles_path(opts) if article_search?
    search_catalog_path(opts)
  end

  def render_search_bar_advanced_widget
    render partial:'catalog/search_bar_advanced_widget'
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
  def active_class_for_current_page(page)
    if current_page?(page)
      "active"
    end
  end
  def disabled_class_for_current_page(page)
    if current_page?(page)
      "disabled"
    end
  end
  def disabled_class_for_no_selections(count)
    if count == 0
      "disabled"
    end
  end
  def from_advanced_search?
    params[:search_field] == 'advanced'
  end

  def link_to_catalog_search
    if article_search?
      mapped_params = { q: params[:q] }
      mapped_params[:search_field] = blacklight_config.index.search_field_mapping[params[:search_field].to_sym] if params[:search_field]
    end
    link_to_unless(
      controller_name == 'catalog',
      t('searchworks.search_dropdown.catalog.description_html'),
      root_path(mapped_params)
    )
  end

  def link_to_article_search
    unless article_search?
      mapped_params = { q: params[:q] }
      mapped_params[:search_field] = blacklight_config.index.search_field_mapping[params[:search_field].to_sym] if params[:search_field]
    end
    link_to_unless(
      controller_name == 'articles',
      t('searchworks.search_dropdown.articles.description_html'),
      articles_path(mapped_params)
    )
  end
end
