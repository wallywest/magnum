module Magnum
  class DestinationPersistence

    DESTINATION_DTYPE = "D"
    VLABEL_DTYPE = "O"
    MEDIAFILE_DTYPE = "P"

    def initialize(routes)
      @routes = routes
    end

    def lookup_dtype(destination)
      case destination.type
      when "MediaFile"
        dtype = MEDIAFILE_DTYPE
      when "VlabelMap"
        dtype = VLABEL_DTYPE
      else
        dtype = lookup_destination_type(destination.destination_id)
      end
      dtype
    end

    def yacc_destination
      Magnum::connection[:yacc_destination]
    end

    def yacc_destination_property
      Magnum::connection[:yacc_destination_property]
    end

    def group_by_dtype
      load_destinations.select_hash_groups(:dtype, :destination_id)
    end

    def destinations
      @routes.collect(&:allocations).flatten.collect(&:simple_destinations).flatten
    end

    def destination_ids
      coll = destinations.group_by{|x| x[:exit_type]}
      h = coll["Destination"] ||= []
      h.map{|x| x[:exit_id]}.uniq
    end

    def load_destinations
      yacc_destination.
        join(:yacc_destination_property,
          :app_id => :app_id, 
          :destination_property_name => :destination_property_name).
        where(:destination_id => destination_ids)
    end

    def lookup_destination_type(id)
      group_by_dtype.each do |type,ids|
        return type if ids.include?(id)
      end
      return DESTINATION_DTYPE
    end
  end
end

