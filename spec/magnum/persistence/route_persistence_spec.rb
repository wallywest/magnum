require 'spec_helper'

describe "Route Persistence" do

  let(:filter) {{:route_name=>["label_1"], :app_id=>8245}}

  let(:persistence) {
    Magnum::RoutePersistence.new(mock_routes,filter)
  }
  let(:persistence_with_adr) {
    Magnum::RoutePersistence.new(mock_adr_routes,filter)
  }
  let(:persistence_with_dequeue) {
    Magnum::RoutePersistence.new(mock_dequeue_routes,filter)
  }

  before do
    @time_local = Time.local(1990)
    Timecop.freeze(@time_local)
    Magnum::stub(:connection).and_return(Sequel::DATABASES.first)
  end

  after do
    Timecop.return
  end

  it "should include the yacc tables" do
    expect(persistence.yacc_vlabel_map_ds.sql).to eq("SELECT * FROM `yacc_vlabel_map`")
    expect(persistence.yacc_route_ds.sql).to eq("SELECT * FROM `yacc_route`")
    expect(persistence.yacc_route_destination_xref_ds.sql).to eq("SELECT * FROM `yacc_route_destination_xref`")
  end


  describe "#save" do
    it "should run the opimtimized methods" do
      expect(persistence).to receive(:create_rows)
      expect(persistence).to receive(:clear_existing_routes)
      expect(persistence).to receive(:write_xrefs)

      persistence.save
    end

    it "should raise an error for the transaction" do
      persistence.stub(:clear_existing_routes).and_raise(Sequel::Rollback)
      expect(proc{persistence.save}).to raise_error(Magnum::PersistenceError, "Activation has failed")
    end
  end

  describe "delete_labels" do
    it "should filter the labels to delete based on existing stored labels" do
      ds = Sequel.mock.dataset
      persistence.stub(:yacc_vlabel_map_ds).and_return(ds)
      expect(ds).to receive(:where).with({:vlabel=>["label_1"], :app_id=>8245}).and_return(ds)
      expect(ds).to receive(:delete)

      persistence.delete_labels
    end
  end

  describe "delete_routes" do
    it "should clear existing routes" do
      expect(persistence).to receive(:clear_existing_routes)
      persistence.delete_routes
    end

    it "should call delete labels with flag" do
      expect(persistence).to receive(:delete_labels)
      persistence.delete_routes(true)
    end

    it "should raise an error for the transaction" do
      persistence.stub(:clear_existing_routes).and_raise(Sequel::Rollback)
      expect(proc{persistence.delete_routes}).to raise_error(Magnum::PersistenceError, "Failed updating routes")
    end
  end

  describe "clear_existing_routes" do
    it "should find the yacc_routes based on the filter" do
      ds = Sequel.mock.dataset
      ds2 = Sequel.mock.dataset
      persistence.stub(:yacc_route_ds).and_return(ds)
      persistence.stub(:yacc_route_destination_xref_ds).and_return(ds2)

      expect(ds).to receive(:where).with(filter).and_return(ds)
      expect(ds).to receive(:select).and_return([])
      expect(ds2).to receive(:where).with({:route_id => []}).and_return(ds2)
      expect(ds2).to receive(:delete)
      expect(ds).to receive(:delete)

      persistence.clear_existing_routes
    end
  end

  describe "write_routes" do
    it "should insert values into yacc routes" do
      persistence.stub(:rand).and_return(1)
      persistence.stub(:write_xrefs)
      routes = [{:app_id=>8245, :route_name=>"label_1", :day_of_week=>192, :begin_time=>0, :end_time=>1439, :distribution_percentage=>"100", :destid=>1, :updated_at => @time_local},
                {:app_id=>8245, :route_name=>"label_1", :day_of_week=>62, :begin_time=>0, :end_time=>1439, :distribution_percentage=>"100", :destid=>1, :updated_at => @time_local}]

      expect(persistence).to receive(:insert).with(:yacc_route_ds,routes)

      persistence.save
    end
  end

  describe "write_xrefs" do
    it "should write multiple xref rows for adr values" do
      persistence_with_adr.stub(:rand).and_return(1)
      persistence_with_adr.stub(:clear_existing_routes)
      routes = [{:app_id=>8245, :route_name=>"label_1", :day_of_week=>192, :begin_time=>0, :end_time=>1439, :distribution_percentage=>"100", :destid=>1, :updated_at => @time_local},
                {:app_id=>8245, :route_name=>"label_1", :day_of_week=>62, :begin_time=>0, :end_time=>1439, :distribution_percentage=>"100", :destid=>1, :updated_at => @time_local}]

      ds = Sequel.mock.dataset
      persistence_with_adr.stub(:yacc_route_ds).and_return(ds)
      ds.stub_chain(:where,:select,:order_by,:to_a).and_return([{:route_id=>1}, {:route_id=>2}])

      expect(persistence_with_adr).to receive(:insert).with(:yacc_route_ds,routes)

      expect(persistence_with_adr).to receive(:insert).with(:yacc_route_destination_xref_ds,[
        {:app_id=>8245, :route_id=>1, :route_order=>1, :destination_id=>1, :transfer_lookup=>"", :dequeue_label=>"", :dtype=>"D", :exit_type=>"Destination", :updated_at => @time_local},
        {:app_id=>8245, :route_id=>1, :route_order=>2, :destination_id=>2, :transfer_lookup=>"", :dequeue_label=>"", :dtype=>"D", :exit_type=>"Destination", :updated_at => @time_local},
        {:app_id=>8245, :route_id=>2, :route_order=>1, :destination_id=>2, :transfer_lookup=>"", :dequeue_label=>"", :dtype=>"O", :exit_type=>"VlabelMap", :updated_at => @time_local},
        {:app_id=>8245, :route_id=>2, :route_order=>2, :destination_id=>3, :transfer_lookup=>"", :dequeue_label=>"", :dtype=>"O", :exit_type=>"VlabelMap", :updated_at => @time_local}
      ])

      persistence_with_adr.save
    end
  end

  it "should write the correct transfer lookup and dequeue for rows with dequeues" do
    persistence_with_dequeue.stub(:rand).and_return(1)
    persistence_with_dequeue.stub(:clear_existing_routes)
    routes = [{:app_id=>8245, :route_name=>"label_1", :day_of_week=>192, :begin_time=>0, :end_time=>1439, :distribution_percentage=>"100", :destid=>1, :updated_at => @time_local},
              {:app_id=>8245, :route_name=>"label_1", :day_of_week=>62, :begin_time=>0, :end_time=>1439, :distribution_percentage=>"100", :destid=>1, :updated_at => @time_local}]
    ds = Sequel.mock.dataset
    persistence_with_dequeue.stub(:yacc_route_ds).and_return(ds)
    ds.stub_chain(:where,:select,:order_by,:to_a).and_return([{:route_id=>1}, {:route_id=>2}])

    expect(persistence_with_dequeue).to receive(:insert).with(:yacc_route_ds,routes)

    expect(persistence_with_dequeue).to receive(:insert).with(:yacc_route_destination_xref_ds,[
      {:app_id=>8245, :route_id=>1, :route_order=>1, :destination_id=>1, :transfer_lookup=>"O", :dequeue_label=>"label_99", :dtype=>"D", :exit_type=>"Destination", :updated_at => @time_local},
      {:app_id=>8245, :route_id=>1, :route_order=>2, :destination_id=>2, :transfer_lookup=>"", :dequeue_label=>"", :dtype=>"D", :exit_type=>"Destination", :updated_at => @time_local},
      {:app_id=>8245, :route_id=>2, :route_order=>1, :destination_id=>2, :transfer_lookup=>"O", :dequeue_label=>"label_20", :dtype=>"O", :exit_type=>"VlabelMap", :updated_at => @time_local},
      {:app_id=>8245, :route_id=>2, :route_order=>2, :destination_id=>3, :transfer_lookup=>"", :dequeue_label=>"", :dtype=>"O", :exit_type=>"VlabelMap", :updated_at => @time_local}
    ])

    persistence_with_dequeue.save
  end

end
