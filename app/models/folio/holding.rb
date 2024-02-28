module Folio
  class Holding
    BoundWithParent = Struct.new(:item, :holding, :instance, keyword_init: true)

    attr_reader :id, :effective_location, :holdings_type, :bound_with_parent

    def initialize(id:, effective_location:, holdings_type:, bound_with_parent:)
      @id = id
      @effective_location = effective_location
      @holdings_type = holdings_type
      @bound_with_parent = bound_with_parent unless bound_with_parent.nil?
    end

    def bound_with?
      holdings_type == 'Bound-with'
    end

    def self.from_dynamic(json)
      new(id: json.fetch('id'),
          effective_location: Folio::Location.from_dynamic(json.fetch('location').fetch('effectiveLocation')),
          holdings_type: json.dig('holdingsType', 'name'),
          bound_with_parent: if json.key?('boundWith') && json['boundWith'].is_a?(Hash)
                               BoundWithParent.new(**json['boundWith'].slice('item', 'holding', 'instance'))
                             end)
    end
  end
end
