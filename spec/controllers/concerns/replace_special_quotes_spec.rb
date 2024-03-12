# encoding: utf-8
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReplaceSpecialQuotes do
  let(:controller) { double('CatalogContrller') }
  let(:q) { 'query' }

  before do
    controller.extend(ReplaceSpecialQuotes)
    allow(controller).to receive(:params).and_return(params)
  end

  describe "with special quotes" do
    let(:params) { { clause: { '1': { query: "«#{q}» ‘#{q}’ ‚#{q}‛ “#{q}” „#{q}‟ ‹#{q}› 「#{q}」『#{q}』 〝#{q}〞 〟#{q}〟 ﹂#{q}﹁  ﹄#{q}﹃ ＂#{q}＂ ｢#{q}｣" } } }.with_indifferent_access }

    it "should replace the special quote characters w/ actual quote characters" do
      controller.send(:replace_special_quotes)
      expect(params.dig(:clause, '1', :query).scan("\"#{q}\"").length).to eq 14
      ["«", "「", "〟", "』"].each do |character|
        expect(params.dig(:clause, '1', :query)).not_to include(character)
      end
    end
  end

  describe 'with special single quotes' do
    context 'when there is only one single quotation mark in the string' do
      let(:params) do
        {
          clause: {
            a_param: { query: "#{q}‘s" },
            b_param: { query: "#{q}’s" },
            c_param: { query: "#{q}‚s" },
            d_param: { query:  "#{q}‛s" }
          }
        }.with_indifferent_access
      end

      it 'should be replaced with an apostrophe' do
        controller.send(:replace_special_quotes)

        expect(params.dig(:clause, :a_param, :query)).to eq "query's"
        expect(params.dig(:clause, :b_param, :query)).to eq "query's"
        expect(params.dig(:clause, :c_param, :query)).to eq "query's"
        expect(params.dig(:clause, :d_param, :query)).to eq "query's"
      end
    end

    context 'when there are multiple single quotation marks in the string' do
      let(:params) do
        {
          clause: {
            a_param: { query: "‘#{q}‘" },
            b_param: { query: "’#{q}’" },
            c_param: { query: "‚#{q}‚" },
            d_param: { query: "‛#{q}‛" }
          }
        }.with_indifferent_access
      end

      it 'should be replaced with the standard double quote character' do
        controller.send(:replace_special_quotes)

        expect(params.dig(:clause, :a_param, :query)).to eq '"query"'
        expect(params.dig(:clause, :b_param, :query)).to eq '"query"'
        expect(params.dig(:clause, :c_param, :query)).to eq '"query"'
        expect(params.dig(:clause, :d_param, :query)).to eq '"query"'
      end
    end
  end

  describe "without special quotes" do
    let(:params) { { clause: { '1': { query: 'Hello' } } }.with_indifferent_access }

    it "should not modify the parameter" do
      expect(params.dig(:clause, '1', :query)).to eq 'Hello'
      controller.send(:replace_special_quotes)
      expect(params.dig(:clause, '1', :query)).to eq 'Hello'
    end
  end
end
