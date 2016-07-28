module Magnum
  class VlabelQueryBase
    attr_reader :app_id, :labels

    def initialize(app_id, labels = nil)
      @app_id = app_id
      @labels = (labels || [''])
    end

    private

    def ds
      Magnum::connection[:yacc_vlabel_map]
    end
  end
end
