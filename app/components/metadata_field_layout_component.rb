class MetadataFieldLayoutComponent < Blacklight::MetadataFieldLayoutComponent
  def initialize(field:, label_class: '', value_class: '')
    super(field:, label_class: 'col-md-3', value_class: 'col-md-9')
  end
end
