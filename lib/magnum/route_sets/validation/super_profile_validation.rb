module Magnum
  module RouteSets
    module SuperProfileValidations
      extend ActiveSupport::Concern

      include ActiveModel::Validations
      include Magnum::Validations

      included do
        validate :total_segment_days
        validate :persisted_vlabels
        validate :persisted_destinations
        validate :total_day_ranges

        validate :validate_mapping_keys
        validate :validate_segments_have_all_labels
        validate :validate_total_percentage_of_allocations

        validate :validate_feature_queuing_active, :if => Proc.new {|sp| sp.has_dequeue?}
        validate :validate_dequeue_route, :if => Proc.new{|sp| sp.has_dequeue?}
      end

      def validate_mapping_keys
        flatten_tree = tree.flatten
        return if flatten_tree.blank?
        flatten_tree.each do |key,value|
          segment_id = key[0]
          vlabel_id = key[1]
          allocation_ids = value
          [["segment",segment_id],["label",vlabel_id],["allocation",allocation_ids]].each do |pair|
            unless self.has_key?(pair[0],pair[1])
              errors.add(:base, "Tree must have valid keys")
              return
            end
          end
        end
      end

      def validate_segments_have_all_labels
        total_labels = labels.select{|x| !x.isDelete}.map(&:id)
        tree.mapping.each do |segment,label|
          vids = label.keys
          diff = total_labels - vids
          if diff.size > 0
            errors.add(:base,"Segments must contain all labels in the tree")
            return
          end
        end
      end
    end
  end
end
