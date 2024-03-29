# frozen_string_literal: true

require 'rails_helper'

class DatabaseDocumentTest < Hash
  include DatabaseDocument
  def document_formats
    self[:the_format]
  end
end

RSpec.describe DatabaseDocument do
  describe "#is_a_database?" do
    let(:document) { DatabaseDocumentTest.new }

    it "returns true for databases" do
      document[:the_format] = ["Book", "Database"]
      expect(document.is_a_database?).to be_truthy
    end
    it "return false non-databases" do
      document[:the_format] = ["Not a db"]
      expect(document.is_a_database?).to be_falsey
    end
  end
end
