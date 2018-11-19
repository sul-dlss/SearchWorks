require 'spec_helper'

describe Holdings::Status::InProcess do
  describe 'in_process libraries' do
    let(:in_process_libraries) { %w[HV-ARCHIVE] }

    it 'should identify any items as in_process' do
      in_process_libraries.each do |library|
        expect(Holdings::Status::InProcess.new(OpenStruct.new(library: library))).to be_in_process
      end
    end
  end
end
