require 'spec_helper'

describe Magnum::CircularVlabelQuery do
  let(:query) { Magnum::CircularVlabelQuery.new(app_id, dequeue_labels)}
  let(:app_id) { 1 }
  let(:dequeue_labels) { %w(foo bar baz) }

  let(:circular_labels) do
    [
      { vlabel_map_id: 4 },
      { vlabel_map_id: 5 },
      { vlabel_map_id: 6 }
    ]
  end

  describe '#ids' do
    it 'maps the vlabel_map_ids' do
      expect(query).to receive(:run).and_return circular_labels
      expect(query.ids).to match_array [4, 5, 6]
    end

    it 'returns an empty array' do
      expect(query).to receive(:run).and_return []
      expect(query.ids).to eq []
    end
  end

end