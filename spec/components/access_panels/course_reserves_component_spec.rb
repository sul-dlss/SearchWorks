# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessPanels::CourseReservesComponent do
  describe "render?" do
    let(:course) { CourseReserve.all.first }

    it "should have a course reserve present" do
      doc = SolrDocument.new(id: '123', courses_folio_id_ssim: [course.id])
      expect(described_class.new(document: doc).render?).to be true
    end

    it "should not have a course reserve present" do
      doc = SolrDocument.new(id: '123')
      expect(described_class.new(document: doc).render?).to be false
    end
  end
end
