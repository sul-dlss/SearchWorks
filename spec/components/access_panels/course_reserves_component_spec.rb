require 'rails_helper'

RSpec.describe AccessPanels::CourseReservesComponent do
  describe "render?" do
    it "should have a course reserve present" do
      doc = SolrDocument.new(id: '123', crez_course_info: ["CAT-401-01-01 -|- Emergency Kittenz -|- McDonald, Ronald"])
      expect(described_class.new(document: doc).render?).to be true
    end

    it "should not have a course reserve present" do
      doc = SolrDocument.new(id: '123')
      expect(described_class.new(document: doc).render?).to be false
    end
  end
end
