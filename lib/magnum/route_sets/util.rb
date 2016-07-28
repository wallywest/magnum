require 'set'

module Magnum
  module Util

    def label_hash
      h = Hash.new
      return h if (self.labels.blank?)
      self.labels.each do |l|
        h[l.id] = []
      end
      h
    end

    def find_label(id)
      self.labels.select{|f| f.id == id}.first
    end

    def find_allocation(id)
      if id.class == Array
        self.allocations.select{|f| id.include?(f.id)}
      else
        self.allocations.select{|f| f.id == id}.first
      end
    end

    def find_segment(id)
      self.segments.select{|f| f.id == id}.first
    end

    def has_key?(type,id)
      return false if id.blank?
      value = self.send("find_#{type}",id)
      case type
      when "segment"
        return !value.blank?
      when "allocation"
        return value.size == id.uniq.size
      when "label"
        return !value.blank?
      end
    end

    def squash(mapping,bitshift=true)
      ranges = {}
      mapping.each_pair do |binary,segs|
        pairings = segs.map{|x| [x.start,x.end]} 
        pairings.each do |pair|
          current = ranges[pair] ||= 0b00000000
          if bitshift
            ranges[pair] = current + (binary.to_s(2) + "0").to_i(2)
          else
            ranges[pair] = current + (binary.to_s(2)).to_i(2)
          end
        end
      end
      ranges
    end

    def equalAllocation(source_id,destination_id)
      source_node = tree.find_segment_node(source_id)
      target_node = tree.find_segment_node(destination_id)
      target_node.each do |key,allocations|
        source = self.find_allocation(source_node[key]).map{|a| a.value}
        target = self.find_allocation(allocations).map{|a| a.value}
        return false if (source != target)
      end
      true
    end

    def findOrCreateSegment(set,can_create)
      seg = self.segments.find do |segment|
        segment.equal(set)
      end
      if seg.blank?
        return newSegment(set) if can_create
        raise Magnum::Error.new("Error importing label.  Please make sure the time segments for this label match those in this Super Profile.")
      end
      seg
    end

    def findOrCreateAllocation(set)
      newAllocation(set)
    end

    def newSegment(set)
      v = set.to_a
      seg = Magnum::Segment.new({:id => uniqueId, :days=> v[0], :start_time => v[1], :end_time=> v[2]})
      self.add_segment(seg)
      seg
    end

    def newAllocation(set)
      v = set.to_a
      alloc = Magnum::Allocation.new({:id => uniqueId, :percentage => v[0], :destinations => []})
      alloc.add_destinations(v[1])
      alloc
    end

    def uniqueId
      SecureRandom.uuid
    end

    def deepClone(origin)
      Marshal::load(Marshal.dump(origin))
    end

    def padding(length,s)
      zs = (length - s.length)
      zs = 0 if zs < 0
      value = ("0" * zs) + s
      value
    end

    def toOctet(binary)
      (binary + "0").to_i(2)
    end

    def yacc_row(segment,label)
      segment.build_utc_segments
      values = squash(segment.utc_segments)
      out = values.map do |times, binary|
       {:day_of_week => binary, :begin_time => times[0], :end_time => times[1], :app_id => self.app_id, :route_name => label.vlabel}
      end
      out
    end

    def build_segment(segment)
      segment.build_utc_segments
      route_pairings = squash(segment.utc_segments)
      node = tree.find_segment_node(segment.id)
      route_pairings.each do |range,days|
        node.each do |label_id,allocations|
          data_allocations = allocations.map{|x| find_allocation(x)}
          yield Magnum::Route.new(self.app_id,find_label(label_id).vlabel,days,range.first,range.last,data_allocations)
        end
      end
    end

    def find_allocation_node(segment_id, label_id)
      dest_ids = self.tree[segment_id][label_id]
      allocations = find_allocation(dest_ids)
      allocations
    end
  end
end
