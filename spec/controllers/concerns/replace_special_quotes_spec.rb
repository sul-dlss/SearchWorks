# encoding: utf-8

require "spec_helper"

describe ReplaceSpecialQuotes do
  let(:controller) { double('CatalogContrller') }
  let(:q) { 'query' }  

  before do
    controller.extend(ReplaceSpecialQuotes)
    allow(controller).to receive(:modifiable_params_keys).and_return(['a_param'])
    allow(controller).to receive(:params).and_return(HashWithIndifferentAccess.new(params))
  end

  describe "with special quotes" do
    let(:params) { { a_param: "«#{q}» ‘#{q}’ ‚#{q}‛ “#{q}” „#{q}‟ ‹#{q}› 「#{q}」『#{q}』 〝#{q}〞 〟#{q}〟 ﹂#{q}﹁  ﹄#{q}﹃ ＂#{q}＂ ｢#{q}｣" } }

    it "should replace the special quote characters w/ actual quote characters" do
      controller.send(:replace_special_quotes)
      expect(params[:a_param].scan("\"#{q}\"").length).to eq 14
      ["«", "「", "〟", "』"].each do |character|
        expect(params[:a_param]).not_to include(character)
      end
    end
  end

  describe "without special quotes" do
    let(:params) { { a_param: 'Hello' } }

    it "should not modify the parameter" do
      controller.send(:replace_special_quotes)
      expect(params[:a_param]).to eq 'Hello'
    end
  end
end
