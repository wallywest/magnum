module Magnum
  class Diff
    def initialize(type,old,new)
      @old = Magnum.build(type,old)
      @new = Magnum.build(type,new)
    end

    def dirty_labels
      return @old.labels.map(&:id) if @new.labels.blank?
      @old.labels.map(&:id) - @new.labels.map(&:id)
    end

  end
end
 
