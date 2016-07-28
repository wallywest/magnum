require 'set'

module Magnum
  module RouteSets
    module SuperProfileConversion
      def mergePackage(pkg)
        can_create_segments = true if self.empty?

        package = Magnum::PackageSerializer.new(pkg).as_json(root: :package)[:package]
        label = Magnum::Label.new({:id => "#{package[:vlabel_id]}", :vlabel => package[:vlabel], :description => package[:vlabel_map_description]})
        self.add_label(label);
        package[:profiles].each do |profile|
          days = profile[:dayString]
          profile[:time_segments].each do |segment|
            seg = Set.new [days, segment[:start_min],segment[:end_min]]
            msegment = self.findOrCreateSegment(seg,can_create_segments)
            segment[:routings].each do |routing|
              percentage = "#{routing[:percentage]}"
              destinations = routing[:routing_exits].map{|x| x.except(:id,:call_priority)}
              destinations.each {|x| x[:requires_dequeue] = true unless x[:dequeue_label].blank? }
              a = Set.new [percentage,destinations]
              allocation = self.newAllocation(a)
              self.add_allocation(msegment,label,allocation)
            end
          end
        end
        cleanup
      end

      def convertToPackage(labelId)
        package = Magnum::Package.new({:app_id => self.app_id,:time_zone => self.time_zone})
        self.segments.group_by(&:days).each do |day,segments|
          profile = package.add_profile(segments.first.splitDays)
          segments.each do |segment|
            seg = profile.add_segment({:start_min => segment.start_time, :end_min => segment.end_time})
            allocation_ids = self.tree.find_segment_node(segment.id)[labelId]
            used_allocations = self.allocations.select{|a| allocation_ids.include?(a.id)}.group_by(&:percentage)
            used_allocations.each do |percentage, allocations|
              allocations.each do |allocation|
                routing = seg.add_routing({:percentage => allocation.percentage})
                allocation.destinations.each_with_index do |destination,index|
                  attributes = { exit_id: destination.destination_id,
                                 exit_type: destination.type,
                                 call_priority: index + 1 }
                  attributes[:dequeue_label] = destination.dequeue unless destination.dequeue.blank?
                  routing.add_routing_exit(attributes)
                end
              end
            end
          end
        end
        cleanup
        package.extend(Magnum::PackageRepresenter)
        package.as_json
      end

      def extractPackage(labelId)
        removeLabel = self.labels.select{|x| x.id == labelId}.first
        attrs = convertToPackage(labelId)
        self.remove_label(removeLabel)
        attrs
      end

      def convertTimeZone(timezone)
        convertTree(timezone)
        self.time_zone = timezone
      end


      def convertTree(time_zone)
        mappings = Magnum::TimeZone::Converter.new(self,time_zone).convert
        mappings.each do |mapping|
          original = self.find_segment(mapping.set.first)
          mapping.segments.each do |value|
            s = Set.new [padding(7,value[0].to_s(2)),value[1],value[2]]
            segment = self.newSegment(s)
            segment.time_zone = time_zone
            self.clone_segment(original,segment)
          end
          mapping.set.each do |segment_id|
            seg = self.find_segment(segment_id)
            self.remove_segment(seg)
          end
        end
        self.time_zone = time_zone
      end
    end
  end
end
