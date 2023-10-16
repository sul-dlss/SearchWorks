require 'rails_helper'

RSpec.describe CourseReserveAccessPointHelper do
  describe "#create_course" do
    describe "when no document is present" do
      it "should return parameter values" do
        params[:f] = { course: ["SOULSTEEP-101"], instructor: ["Winfrey, Oprah"] }
        expect(response).to receive(:docs).exactly(1).times.and_return([])
        helper.create_course
        expect(helper.instance_variable_get("@course_info").id).to eq "SOULSTEEP-101"
        expect(helper.instance_variable_get("@course_info").instructor).to eq "Winfrey, Oprah"
        expect(helper.instance_variable_get("@course_info").name).to eq ""
      end
    end

    describe "when documents are present" do
      it "should return first document course values that match params" do
        params[:f] = { course: ["CATZ-102"], instructor: ["Cat, Tom"] }
        expect(response).to receive(:docs).exactly(2).times.and_return([{ crez_course_info: ["CATZ-102-|-Mice and Men-|-Cat, Tom", "SOULSTEEP-101-|-42-|-Winfrey, Oprah"] }])
        helper.create_course
        expect(helper.instance_variable_get("@course_info").id).to eq "CATZ-102"
        expect(helper.instance_variable_get("@course_info").instructor).to eq "Cat, Tom"
        expect(helper.instance_variable_get("@course_info").name).to eq "Mice and Men"
      end
    end

    describe "when the course does not exist in the first document" do
      it "should still find the course" do
        params[:f] = { course: ["CATZ-102"], instructor: ["Cat, Tom"] }
        expect(response).to receive(:docs).at_least(:once).and_return([{ crez_course_info: ["SOULSTEEP-101-|-42-|-Winfrey, Oprah"] }, { crez_course_info: ["CATZ-102-|-Mice and Men-|-Cat, Tom"] }])
        helper.create_course
        expect(helper.instance_variable_get("@course_info").id).to eq "CATZ-102"
        expect(helper.instance_variable_get("@course_info").instructor).to eq "Cat, Tom"
        expect(helper.instance_variable_get("@course_info").name).to eq "Mice and Men"
      end
    end
  end
end
