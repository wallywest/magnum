module Magnum
  class SuperProfileTree < OpenStruct
    include Virtus.model

    def initialize(tree = {})
      @tree = tree
    end

    def flatten(hash = @tree, acc_keys = [])
      hash.flat_map do |key, value|
        if value.is_a?(Hash)
          flatten(value, acc_keys + [key])
        else
          {acc_keys + [key] => value}
        end
      end.reduce(:update) || {}
    end

    def mapping
      @tree
    end

    def add_segment(segment,label_node)
      @tree.merge!(segment.id => label_node)
    end

    def remove_segment(segment)
      @tree.reject!{|segment_id| segment_id == segment.id}
    end

    def add_label(label)
      @tree.each_key do |segment_id|
        @tree[segment_id][label.id] = []
      end
    end

    def remove_label(label)
      @tree.each do |segment_id,label_node|
        label_node.reject!{|x,y| x == label.id}
      end
    end

    def remove_allocation(segment,label,allocation)
      tree_allocation = @tree[segment.id][label.id]
      tree_allocation.delete(allocation.id)
    end

    def add_allocation(segment,label,allocation)
      tree_allocation = @tree[segment.id][label.id]
      tree_allocation.push(allocation.id)
    end

    def find_allocation_node(segment_id,label_id)
      @tree[segment_id][label_id]
    end

    def find_segment_node(segment_id)
      @tree[segment_id]
    end
  end
end
