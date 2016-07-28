require 'spec_helper'

describe Magnum::ActiveVlabelQuery do
  let(:query) {Magnum::ActiveVlabelQuery.new(8245,["123456789"])}

  before do
    Magnum::stub(:connection).and_return(Sequel::DATABASES.first)
    @ds = Sequel.mock.dataset
  end
  
  describe 'active vlabels' do
    it 'should return a list of active labels'
    it 'should return active list of one_to_one labels'
    it 'should return active list of one_to_one labels'
  end
end

