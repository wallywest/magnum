require 'benchmark'

module Magnum
  module RouteSets
    module SuperProfileServices

      def activate(options={})
        if options[:update]
          super_profile_update(options)
        else
          super_profile_save
        end
      end

      def delete_dirty_labels
        service = Magnum::Service::DeleteRoutes.new(self,true)
        service.run
        cleanup
      end

      def super_profile_update(options)
        service = Magnum::Service::UpdateRoute::new(self,options)
        service.run
        cleanup
      end

      def super_profile_save
        delete_dirty_labels
        service = Magnum::Service::CreateRoutes::new(self)
        service.run
      end

      def cleanup
        used_allocations = tree.flatten.values.flatten
        allocations.delete_if{|alloc| !used_allocations.include?(alloc.id)}
      end
    end
  end

end
