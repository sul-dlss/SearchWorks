require 'rails_helper'

class CourseReservesTestClass
  include CourseReserves
end

RSpec.describe CourseReserves do
  it "should return nil for non course reserve docs" do
    expect(CourseReservesTestClass.new.course_reserves).to be_nil
  end

  describe "present?" do
    it "should return false" do
      expect(CourseReservesTestClass.new.course_reserves.present?).to be_falsey
    end

    it "should return true" do
      doc = SolrDocument.new(id: '123', crez_course_info: ["CAT-401-01-01 -|- Emergency Kittenz -|- McDonald, Ronald"])
      expect(doc.course_reserves.present?).to be_truthy
    end
  end

  describe CourseReserves::CourseInfo do
    let(:doc) { "CAT-401-01-01 -|- Emergency Kittenz -|- McDonald, Ronald" }
    let(:course_info) { CourseReserves.from_crez_info(doc) }

    it "should initialize a new reservation" do
      expect(course_info).to be_an CourseReserves::CourseInfo
    end

    it "should have the correct id" do
      expect(course_info.id).to eq "CAT-401-01-01"
    end

    it "should have the correct name" do
      expect(course_info.name).to eq "Emergency Kittenz"
    end

    it "should have the correct instructor" do
      expect(course_info.instructor).to eq "McDonald, Ronald"
    end
  end
end
