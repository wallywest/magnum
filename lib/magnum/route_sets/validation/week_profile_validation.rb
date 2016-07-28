module Magnum
  module RouteSets
    module WeekValidation
      extend ActiveSupport::Concern

      include ActiveModel::Validations
      include Magnum::Validations

      included do
        validate :total_day_ranges
        validate :total_segment_days
        validate :persisted_destinations
        validate :validate_mapping_keys
        validate :validate_total_percentage_of_allocations

        validate :validate_feature_queuing_active, :if => Proc.new {|week| week.has_dequeue?}
        #this is causing a tiny_tds timeout error when wrapped in a Vlabel.transaction
        #TODO
        #validate :validate_dequeue_route, :if => Proc.new{|week| week.has_dequeue?}
      end

      def validate_mapping_keys
        flatten_tree = tree.flatten
        return if flatten_tree.blank?
        flatten_tree.each do |key,value|
          segment_id = key[0]
          allocation_ids = value
          [["segment",segment_id],["allocation",allocation_ids]].each do |pair|
            unless self.has_key?(pair[0],pair[1])
              errors.add(:base, "Tree must have valid keys")
              return
            end
          end
        end
      end
    end
  end
end
