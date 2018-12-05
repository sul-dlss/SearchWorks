require 'spec_helper'
require 'access_panels/course_reserve'

describe AccessPanels::CourseReserve do
  describe "present?" do
    it "should have a course reserve present" do
      doc = SolrDocument.new(id: '123', crez_course_info: ["CAT-401-01-01 -|- Emergency Kittenz -|- McDonald, Ronald"])
      expect(described_class.new(doc).present?).to eq true
    end

    it "should not have a course reserve present" do
      doc = SolrDocument.new(id: '123')
      expect(described_class.new(doc).present?).to eq false
    end
  end
end
