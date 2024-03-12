# frozen_string_literal: true

# We may want to abstract this out into a more
# generic ResourceType or DocumentType class that
# can identify all the different types appropriately.
module DatabaseDocument
  def is_a_database?
    document_formats.include? "Database"
  end
end
