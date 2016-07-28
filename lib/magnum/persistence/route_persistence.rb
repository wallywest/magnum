require 'magnum/persistence/filters'

module Magnum
  class RoutePersistence
    attr_reader :routes,:filter

    XREF_ROW = Proc.new {|app_id,route_id,destination_id,type,priority,dequeue_label,transfer_lookup,dtype|
      transfer = transfer_lookup ||= ""
      {
        :app_id => app_id,
        :route_id => route_id,
        :route_order => priority,
        :destination_id => destination_id,
        :transfer_lookup => transfer,
        :dequeue_label => dequeue_label,
        :dtype => dtype,
        :exit_type => type,
        :updated_at => Time.now
      }
    }

    def initialize(routes,filter)
      @routes = routes
      @destination_mapper = DestinationPersistence.new(@routes)
      @app_id = routes.first.app_id
      @filter = filter
      @labels = routes.map{|r| r.route_name}.uniq
      @xrefs = []
      @inserts = []
    end

    def save
      create_rows
      begin
        with_retry_transaction do
          clear_existing_routes
          insert(:yacc_route_ds,@inserts)
          write_xrefs
        end
      rescue Sequel::Rollback
        raise Magnum::PersistenceError, "Activation has failed"
      end
    end

    def delete_routes(delete_labels_flag = false)
      begin
        with_retry_transaction do
          clear_existing_routes
          delete_labels if delete_labels_flag
        end
      rescue Sequel::Rollback
        raise Magnum::PersistenceError, "Failed updating routes"
      end
    end

    def delete_labels
      ds = yacc_vlabel_map_ds.where(:vlabel => @labels, :app_id => @app_id)
      ds.delete
    end

    def clear_existing_routes
      sql = yacc_route_ds.where(@filter)
      route_ids = sql.select(:route_id).to_a.collect{|x| x[:route_id]}
      yacc_route_destination_xref_ds.where(:route_id => route_ids).delete
      sql.delete
    end

    def insert(ds,values)
      self.send(ds).multi_insert(values)
    end

    def create_rows
      @routes.each do |route|
        route.allocations.each do |allocation|
          rname = "#{route.route_name}"
          @inserts << {
              :app_id => route.app_id,
              :route_name => rname,
              :day_of_week => route.day_of_week,
              :begin_time => route.begin_time,
              :end_time => route.end_time,
              :distribution_percentage => allocation.percentage,
              :destid => rand(Time.now.to_i),
              :updated_at => Time.now
          }
         @xrefs << {:destinations => allocation.destinations}
        end
      end
    end

    def write_xrefs
      xref_writes = []
      live_routes.each_with_index do |route,index|
        xref = @xrefs[index]
        create_xrefs(route,xref) {|write| xref_writes << write}
      end
      insert(:yacc_route_destination_xref_ds,xref_writes)
    end

    def create_xrefs(route,xref,&block)
      xref[:destinations].each_with_index do |destination,i|
        ##awesome RACC FLAG
        transfer_lookup = "O" unless destination.dequeue.blank?
        dtype = @destination_mapper.lookup_dtype(destination)
        yield XREF_ROW.call(
          @app_id, 
          route[:route_id],
          destination.destination_id,
          destination.type,
          i+1,
          destination.dequeue,
          transfer_lookup,
          dtype
        )
      end
    end

    def live_routes
      yacc_route_ds.where(@filter).select(:route_id).order_by(:route_id).to_a
    end

    def yacc_route_ds
      Magnum::connection[:yacc_route]
    end

    def yacc_route_destination_xref_ds
      Magnum::connection[:yacc_route_destination_xref]
    end

    def yacc_vlabel_map_ds
      Magnum::connection[:yacc_vlabel_map]
    end


    private 

    def with_retry_transaction
      return unless block_given?
      Magnum::connection.transaction(:retry_on => [Sequel::DatabaseDisconnectError], :num_retries => 2, :rollback => :reraise) do
        yield
      end
    end

  end
end
