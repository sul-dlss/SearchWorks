# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Searchworks4::VolumesModalComponent, type: :component do
  # call_number:, response:, title:
  before do
    render_inline(described_class.new(call_number: 'ABC123', response:, title: 'Official publications'))
  end

  context 'with fewer than five results' do
    let(:response) do
      {
        response: {
          docs: [
            { "id" => "123",
              "title_display" => "Official publications",
              "lc_assigned_callnum_ssim" => ["HF5686.C8 N37"] },
            {
              "id" => "234",
              "title_display" => "Cost of accounting",
              "item_display_struct" => [{
                "id" => "5d715937-11ed-58c3-b3f5-15dd8c11605e",
                "barcode" => "001AKH1250",
                "callnumber" => "380.806 .N277O"
              }]
            }
          ]
        }
      }
    end

    it 'displays call numbers and titles of associated volumes and no search bar' do
      expect(page).to have_css('.callnumber', text: 'HF5686.C8 N37')
      expect(page).to have_css('.callnumber', text: '380.806 .N277O')
      expect(page).to have_content('Official publications')
      expect(page).to have_content('Cost of accounting')
      expect(page).to have_no_field('input[name="volume_suggest"]')
    end
  end

  context 'with five results' do
    let(:response) do
      {
        response: {
          docs: [
            { "id" => "123",
              "title_display" => "Official publications",
              "lc_assigned_callnum_ssim" => ["HF5686.C8 N37"] },
            {
              "id" => "234",
              "title_display" => "Cost of accounting",
              "item_display_struct" => [{
                "id" => "5d715937-11ed-58c3-b3f5-15dd8c11605e",
                "barcode" => "001AKH1250",
                "callnumber" => "380.806 .N277O"
              }]
            },
            { "id" => "123",
              "title_display" => "Accounting",
              "lc_assigned_callnum_ssim" => ["HF5686.C8 N37A"] },
            { "id" => "123",
              "title_display" => "Alchemical reactions",
              "lc_assigned_callnum_ssim" => ["HF5686.C8 N37B"] },
            { "id" => "123",
              "title_display" => "Satirical takes",
              "lc_assigned_callnum_ssim" => ["HF5686.C8 N37C"] }
          ]
        }
      }
    end

    it 'displays call numbers and titles of associated volumes and search bar' do
      expect(page).to have_css('.callnumber', text: 'HF5686.C8 N37A')
      expect(page).to have_css('.callnumber', text: 'HF5686.C8 N37B')
      expect(page).to have_css('.callnumber', text: 'HF5686.C8 N37C')
      expect(page).to have_css('.form-control[name="volume_suggest"]')
    end
  end
end
