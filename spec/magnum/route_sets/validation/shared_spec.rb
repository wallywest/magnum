require 'spec_helper'

describe Magnum::Validations do
  let(:dummy_object) { dummy_class.new }
  let(:dummy_class) { Class.new{ include Magnum::Validations} }

  describe '#dequeues_valid?' do
    it 'is true when there are as many valid ids as dequeues' do
      allow(dummy_object).to receive(:valid_ids).and_return [:foo, :bar, :baz]
      dequeues = [1, 2 ,3]
      expect(dummy_object.send(:dequeues_valid?, dequeues)).to be true
    end

    [
      [[], [:foo]],
      [[1], []],
      [[1], [:foo, :bar]],
      [[1, 2], [:foo]]
    ].each do |context|
      dequeues = context[0]
      valid_ids = context[1]

      it "is false when there are #{valid_ids.size} valid ids and #{dequeues.size} dequeues" do
        allow(dummy_object).to receive(:valid_ids).and_return valid_ids
        expect(dummy_object.send(:dequeues_valid?, dequeues)).to be false
      end
    end

  end

  describe '#valid_ids' do
    [
      #active_label_ids  self_referential_label_ids  expected output
      [[],               [],                         []],
      [[],               [1],                        [1]],
      [[1],              [],                         [1]],
      [[1],              [2],                        [1, 2]],
      [[1],              [1],                        [1]]
    ].each do |context|
      active_label_ids = context[0]
      circular_label_ids = context[1]
      expected_response = context[2]

      it "when the active label ids are #{active_label_ids} and the " +
           "self referential label ids are #{circular_label_ids} it " +
           "responds with #{expected_response}" do
        expect(Magnum::ActiveVlabelQuery).to receive_message_chain(:new, :ids).and_return active_label_ids
        expect(Magnum::CircularVlabelQuery).to receive_message_chain(:new, :ids).and_return circular_label_ids
        expect(dummy_object).to receive(:app_id).twice.and_return 1
        expect(dummy_object.send(:valid_ids, nil)).to match_array expected_response
      end
    end
  end
end