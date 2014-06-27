module MarcCharacteristics
  def marc_characteristics
    return nil unless self.respond_to?(:to_marc)
    marc = self.to_marc
    characteristics = []
    Characteristic.characteristics_labels.keys.each do |tag|
      if marc[tag]
        characteristics_fields = []
        marc.find_all{|f| (tag) === f.tag}.each do |field|
          subfields = field.map do |subfield|
            if ('a'..'z').include?(subfield.code) && !Constants::EXCLUDE_FIELDS.include?(subfield.code)
              subfield.value
            end
          end.compact.join('; ')
          characteristics_fields << "#{subfields}."
        end
        characteristics << MarcCharacteristics::Characteristic.new(tag: tag, values: characteristics_fields)
      end
    end
    characteristics
  end

  private

  class Characteristic
    attr_reader :values
    def initialize(options={})
      @tag = options[:tag]
      @values = options[:values]
    end
    def label
      self.class.characteristics_labels[@tag]
    end
    def self.characteristics_labels
      {'344' => 'Sound',
       '345' => 'Projection',
       '346' => 'Video',
       '347' => 'Digital'}
    end
  end
end
