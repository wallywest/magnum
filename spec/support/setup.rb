require 'securerandom'
require 'oj'

module MagnumTest
  def self.seed
    Dir["./spec/data/**/*.json"].each do |data|
      f = JSON.parse(File.read(data))
      $MAGNUM_COLLECTION.insert(f)
    end
  end

  def self.build_and_seed
    data = File.expand_path("./build.json")
    template = JSON.parse(File.read(data))
    template["time_zone"].each do | time_zone |
      days = template["days"]
      tods = template["tod"]
      allocs = template["allocations"]
      destinations = template["destinations"]

      segments_collection = build_segments_from(days, tods)
      allocations_collection = build_allocations_from(allocs, destinations)

      n = 1
      segments_collection.each do | segments |
        allocations_collection.each do | allocations |
          mock_super_profile = Hash.new
          mock_super_profile["adr"] = true
          mock_super_profile["app_id"] = 8245
          mock_super_profile["labels"] = template["labels"]

          mock_super_profile["time_zone"] = time_zone
          mock_super_profile["segments"] = segments
          mock_super_profile["name"] = "super_profile_#{n}"
          n += 1

          build_tz_tree_from(mock_super_profile, allocations_collection)
          Oj.to_file( "spec/data/integration/#{mock_super_profile["name"]}.json", mock_super_profile, { indent: 1 })

          #$MAGNUM_COLLECTION.insert(mock_super_profile)
        end
      end
    end
  end

  def self.getProfile(name)
    profile = $MAGNUM_COLLECTION.find({:name => name}).first.to_json
    #change this
    sp = Magnum::build(:super_profile, profile)
    sp
  end

  def getRouteSet(name)
    profile = $MAGNUM_COLLECTION.find({:name => name}).first.to_json
    profile
  end

  def self.getValidSuperProfiles
    $MAGNUM_COLLECTION.find({"invalid" => {"$ne" => true}, "type" => {"$ne" => "weekly"}})
  end

  def self.getValidTimeZoneSuperProfiles
    $MAGNUM_COLLECTION.find({"for_tz" => true, "invalid" => {"$ne" => true}, "type" => {"$ne" => "weekly"}})
  end

  def self.getWeeklyProfiles
    $MAGNUM_COLLECTION.find({"invalid" => {"$ne" => true}, "type" => "weekly"})
  end

  def self.getAdrProfiles
    $MAGNUM_COLLECTION.find({"adr" => {"$ne" => false}})
  end

  def self.build_segments_from(dow_array, tod_array)
    # this method returns a collection of day-of-week and time-of-day combinations
    segments_collection = []
    dow_array.each do | dows |
      tod_array.each do | tods |
        each_segment = []

        tods.each do | tod |
          dows.each do | dow |
          s = Hash.new
          s["id"]   = "#{dow["id"]}_#{tod["start_time"]}_#{tod["end_time"]}"
          s["days"] = dow["dow"]
          s["start_time"] = tod["start_time"]
          s["end_time"]   = tod["end_time"]
          each_segment << s
          end
        end

        segments_collection << each_segment
      end
    end
    segments_collection
  end

  def self.build_allocations_from(allocs_array, dest_array)
    allocation_collection = []
    allocs_array.each do | allocs |
      each_alloc = []
      allocs.each do | allocation |
        a = allocation.dup
        a["destinations"] = dest_array[Random.rand(0...dest_array.length)]
        each_alloc << a
      end
      allocation_collection << each_alloc
    end
    allocation_collection
  end

  #def self.build_tree_from(super_profile)
    #super_profile["tree"] = Hash.new
    #super_profile["segments"].each do | s |
      #super_profile["labels"].each do | l |
        #s_id, l_id = s["id"], l["id"]
        #super_profile["tree"][s_id] ||= Hash.new
        #super_profile["tree"][s_id][l_id] = super_profile["allocations"].map {| a | a["id"] }
      #end
    #end
    #super_profile
  #end

  def self.build_tz_tree_from(super_profile, allocations_collection)
    sp_allocs = []
    allocs = allocations_collection.dup
    super_profile["tree"] = Hash.new
    super_profile["segments"].each do | s |
      super_profile["labels"].each do | l |
        s_id, l_id = s["id"], l["id"]
        super_profile["tree"][s_id] ||= Hash.new
        b = allocs[Random.rand(0...allocs.size)]
        current_allocs = b.each_with_object([]) do |value,array|
          clone = value.dup
          clone["id"] = SecureRandom.uuid.to_s
          array << clone
        end
        super_profile["tree"][s_id][l_id] = current_allocs.map {| a | a["id"] }
        sp_allocs.concat(current_allocs)
      end
    end

    super_profile["allocations"] = sp_allocs
    super_profile["for_tz"] = true
    super_profile
  end
end
