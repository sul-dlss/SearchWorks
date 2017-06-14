require 'marc_edition'

module Edition
  def edition
    @edition ||= begin
      if self.respond_to?(:to_marc) && (marc_edition = MarcEdition.new(self.to_marc)).present?
        marc_edition
      end
    end
  end
end
