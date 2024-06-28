# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessPanels::CourseReservesComponent, type: :component do
  describe "render?" do
    before do
      create(:reg_course)
    end

    it "should have a course reserve present" do
      doc = SolrDocument.new(id: '123', courses_folio_id_ssim: ['00254a1b-d0f5-4a9a-88a0-1dd596075d08'])
      expect(described_class.new(document: doc).render?).to be true
    end

    it "should not have a course reserve present" do
      doc = SolrDocument.new(id: '123')
      expect(described_class.new(document: doc).render?).to be false
    end
  end

  describe "document with three course reserves" do
    before do
      create(:reg_course)
      create(:reg_course_add)
      create(:reg_course_third)
    end

    it "should show three course reservations" do
      doc = SolrDocument.new(id: '123',
                             courses_folio_id_ssim: ['00254a1b-d0f5-4a9a-88a0-1dd596075d08',
                                                     '0030dde8-b82d-4585-a049-c630a93b94f2',
                                                     '00a45880-2088-4bbd-8b37-929093f1a032'])
      render_inline(described_class.new(document: doc))
      expect(page).to have_css('div.panel-course-reserve')
      inner_div = page.find('div.panel-course-reserve')
      expect(inner_div).to have_css('dl')
      expect(inner_div).to have_css('dt', count: 3, text: "Course")
      expect(inner_div).to have_css('dt', text: "Course")
      expect(inner_div).to have_css('dd a')
      expect(inner_div).to have_css('dt', text: "Instructor(s)")
    end
  end
end
