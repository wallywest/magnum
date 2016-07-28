module MockRoutes
  def mock_routes
    alloc1 = [Magnum::Allocation.new(:percentage => "100",:id => 1, :destinations => [
      Magnum::Destination.new({"type" => "Destination", "destination_id" => "1", :dequeue => ""})
    ])]

    alloc2 = [Magnum::Allocation.new(:percentage => "100",:id => 2, :destinations => [
      Magnum::Destination.new({"type" => "Destination", "destination_id" => "2", :dequeue => ""})])]
    
    routes = [
      Magnum::Route.new(8245,"label_1",192,0,1439,alloc1),
      Magnum::Route.new(8245,"label_1",62,0,1439,alloc2)
    ]
    routes
  end

  def mock_adr_routes
    alloc3 = [Magnum::Allocation.new(:percentage => "100",:id => 1, :destinations => [
      Magnum::Destination.new({"destination_id" => "1", "type" => "Destination", :dequeue => ""}),
      Magnum::Destination.new({"destination_id" => "2", "type" => "Destination", :dequeue => ""})
    ])]

    alloc4 = [Magnum::Allocation.new(:percentage => "100",:id => 2, :destinations => [
      Magnum::Destination.new({"destination_id" => "2", "type"  => "VlabelMap", :dequeue => ""}),
      Magnum::Destination.new({"destination_id" => "3", "type"  => "VlabelMap", :dequeue => ""})
    ])]

    routes = [
      Magnum::Route.new(8245,"label_1",192,0,1439,alloc3),
      Magnum::Route.new(8245,"label_1",62,0,1439,alloc4)
    ]
    routes
  end

  def mock_dequeue_routes
    alloc3 = [Magnum::Allocation.new(:percentage => "100",:id => 1, :destinations => [
      Magnum::Destination.new({"destination_id" => "1", "type" => "Destination", :dequeue => "label_99"}),
      Magnum::Destination.new({"destination_id" => "2", "type" => "Destination", :dequeue => ""})
    ])]

    alloc4 = [Magnum::Allocation.new(:percentage => "100",:id => 2, :destinations => [
      Magnum::Destination.new({"destination_id" => "2", "type"  => "VlabelMap", :dequeue => "label_20"}),
      Magnum::Destination.new({"destination_id" => "3", "type"  => "VlabelMap", :dequeue => ""})
    ])]

    routes = [
      Magnum::Route.new(8245,"label_1",192,0,1439,alloc3),
      Magnum::Route.new(8245,"label_1",62,0,1439,alloc4)
    ]
    routes
  end

end
