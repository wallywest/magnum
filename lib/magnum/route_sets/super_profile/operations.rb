require 'set'

module Magnum
  module RouteSets
    module SuperProfileOperations
      def add_label(label)
        self.labels << label
        tree.add_label(label)
      end

      def remove_label(label)
        self.labels.delete_if{|l| l.id == label.id}
        tree.remove_label(label)
      end

      def add_segment(segment,clone=false)
        segment.time_zone = self.time_zone
        self.segments << segment unless self.segments.include?(segment)
        tree.add_segment(segment,label_hash)
      end

      def clone_segment(source, destination)
        label_tree = tree.mapping[source.id]
        return if label_tree.empty?
        duplicate_segment_nodes(label_tree,destination)
      end

      def duplicate_segment_nodes(label_tree,destination)
        label_tree.each do |label_id,allocations|
          label = self.find_label(label_id)
          allocs = copyAllocations(allocations)
          allocs.each do |alloc|
            self.add_allocation(destination,label,alloc)
          end
        end
      end

      def remove_segment(segment)
        self.segments.delete_if{|s| s.id == segment.id}
        tree.remove_segment(segment)
      end

      def add_allocation(segment,label,allocation)
        self.allocations << allocation unless self.allocations.include?(allocation)
        tree.add_allocation(segment,label,allocation)
      end

      def remove_allocation(segment,label,allocation)
        tree.remove_allocation(segment,label,allocation)
        self.allocations.reject!{|a| a.id == allocation.id}
      end

      def add_multiple_allocations(segment,label,allocations)
        self.allocations.each do |allocation|
          add_allocation(segment,label,allocation)
        end
      end

      def update_allocations(allocations,segment,label)
        allocation_node = tree.find_allocation_node(segment.id,label.id).dup
        #segment_root[segment.id][label.id].dup

        allocation_node.each do |alloc_id|
          alloc = find_allocation(alloc_id)
          remove_allocation(segment,label,alloc)
        end

        allocations.each do |alloc|
          add_allocation(segment,label,alloc)
        end
      end

      private

      def copyAllocations(allocations)
        allocs = self.find_allocation(allocations)
        a = allocs.map do |alloc|
          a = alloc.clone
          a.id = uniqueId
          a
        end
        a
      end
    end
  end
end
