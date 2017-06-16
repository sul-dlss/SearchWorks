require 'spec_helper'

describe PaginationHelper do

  describe 'label_current_per_page' do
    before { expect(helper).to receive(:current_per_page).and_return(10) }
    it 'labels current per page' do
      expect(helper.label_current_per_page(10,'kitten')).to eql '<span class="glyphicon glyphicon-ok"></span> kitten'
    end
    it 'labels per page that is not current' do
      expect(helper.label_current_per_page(20,'kitten')).to eql 'kitten'
    end
  end

  describe 'label_current_sort' do
    def field(value)
      instance_double('field', label: value, field: value)
    end

    before { expect(helper).to receive(:current_sort_field).and_return(field('relevance')) }

    it 'labels current sort' do
      expect(helper.label_current_sort(field('relevance'))).to eql '<span class="glyphicon glyphicon-ok"></span> Relevance'
    end
    it 'labels sort that is not current' do
      expect(helper.label_current_sort(field('Title'))).to eql 'Title'
    end
  end

end
