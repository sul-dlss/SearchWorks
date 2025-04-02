# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessPanels::CourseReservesComponent, type: :component do
  let(:component) { described_class.new(document:) }

  describe "render?" do
    before do
      create(:reg_course)
    end

    context 'has course reserve present' do
      let(:document) { SolrDocument.new(id: '123', courses_folio_id_ssim: ['00254a1b-d0f5-4a9a-88a0-1dd596075d08']) }

      it { expect(component.render?).to be true }
    end

    context "does not have a course reserve present" do
      let(:document) { SolrDocument.new(id: '123') }

      it { expect(component.render?).to be false }
    end
  end

  describe "document with three course reserves" do
    before do
      create(:reg_course)
      create(:reg_course_add)
      create(:reg_course_third)
      render_inline(component)
    end

    let(:document) {
      SolrDocument.new(id: '123',
                       courses_folio_id_ssim: ['00254a1b-d0f5-4a9a-88a0-1dd596075d08',
                                               '0030dde8-b82d-4585-a049-c630a93b94f2',
                                               '00a45880-2088-4bbd-8b37-929093f1a032'])
    }

    it "should show three course reservations" do
      expect(page).to have_css('div.panel-course-reserve')
      expect(page).to have_css('dl')
      expect(page).to have_css('dt', count: 3, text: "Course")
      expect(page).to have_css('dt', text: "Course")
      expect(page).to have_css('dd a')
      expect(page).to have_css('dt', text: "Instructor(s)")
    end

    it "should have all three links correctly formatted" do
      expect(page).to have_link('ENGLISH-17Q-01 -- After 2001: A 21st Century Science Fiction Odyssey',
                                href: '/catalog?f%5Bcourses_folio_id_ssim%5D%5B%5D=00254a1b-d0f5-4a9a-88a0-1dd596075d08')

      expect(page).to have_link("SEMINAR -- James Joyce's Ulysses: Directed Reading",
                                href: '/catalog?f%5Bcourses_folio_id_ssim%5D%5B%5D=00a45880-2088-4bbd-8b37-929093f1a032')

      expect(page).to have_link('CEE-270-01 -- Movement and Fate of Organic Contaminants in Waters',
                                href: '/catalog?f%5Bcourses_folio_id_ssim%5D%5B%5D=0030dde8-b82d-4585-a049-c630a93b94f2')
    end
  end
end
