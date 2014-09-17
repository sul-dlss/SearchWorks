module Imprint
  def imprint
    @imprint ||= begin
      if self.respond_to?(:to_marc) && (marc_imprint = MarcImprint.new(self.to_marc)).present?
        marc_imprint
      end
    end
  end
end
