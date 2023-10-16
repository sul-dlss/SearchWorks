require 'rails_helper'

class CallnumberSearchTestClass
  include CallnumberSearch
end

RSpec.describe CallnumberSearch do
  let(:subject) { CallnumberSearchTestClass.new }

  describe "#quote_and_downcase_callnumber_search" do
    let(:params) { { search_field: 'call_number', q: 'ABC 123' } }

    before do
      allow(subject).to receive(:params).and_return(params)
      subject.send(:quote_and_downcase_callnumber_search)
    end

    it "should downcase the q parameter" do
      expect(params[:q]).to match /abc 123/
      expect(params[:q]).not_to include "ABC"
    end
    it "should quote the q parameter" do
      expect(params[:q]).to eq '"abc 123"'
    end
    describe "when already quoted" do
      let(:params) { { search_field: 'call_number', q: '"ABC 123"' } }

      before do
        allow(subject).to receive(:params).and_return(params)
        subject.send(:quote_and_downcase_callnumber_search)
      end

      it "should not double quote" do
        expect(params[:q]).to eq '"abc 123"'
      end
    end

    describe "when not a callnumber search" do
      let(:params) { { search_field: 'not_callnumber', q: 'ABC 123' } }

      before do
        allow(subject).to receive(:params).and_return(params)
      end

      it "should not change the q parameter" do
        subject.send(:quote_and_downcase_callnumber_search)
        expect(params[:q]).to eq 'ABC 123'
      end
    end

    describe "when a search term is not given" do
      let(:params) { { search_field: 'call_number' } }

      before do
        allow(subject).to receive(:params).and_return(params)
      end

      it "should not change any parameters" do
        subject.send(:quote_and_downcase_callnumber_search)
        expect(params).to eq params
      end
    end
  end
end
